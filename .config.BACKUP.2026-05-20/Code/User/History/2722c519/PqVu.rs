//! Interactive terminal chat UI for IA Chat MVP.
//!
//! Provides a terminal-based chat interface with:
//! - Colored user/assistant messages
//! - Streaming response simulation (token-by-token display)
//! - Status indicator showing current state
//! - Commands: `/exit`, `/help`, `/clear`, `/model <name>`
//!
//! Run with: `cargo run --bin chat_ui`

use std::io::{stdout, Write};
use std::sync::Arc;
use std::time::Duration;

use anyhow::Result;
use crossterm::{
    cursor,
    event::{self, Event, KeyCode, KeyModifiers},
    style::{self},
    terminal::{self, Clear, ClearType},
    execute,
};
use tokio::time::sleep;

use ia_chat_mvp::chat::{
    orchestrator::ChatOrchestrator,
    providers::MockLlmClient,
    state::ChatState,
    tools::ToolRegistry,
};

// ---------------------------------------------------------------------------
// Mock response — simulates a tokenised LLM reply so streaming is visible
// ---------------------------------------------------------------------------
const RESPONSE_TOKENS: &[&str] = &[
    "¡Hola! ",
    "Soy ",
    "el ",
    "asistente ",
    "virtual. ",
    "¿En ",
    "qué ",
    "puedo ",
    "ayudarte?",
];

// ---------------------------------------------------------------------------
// Helpers — print styled text with proper raw-mode newlines (\r\n)
// ---------------------------------------------------------------------------

/// Write a line of text in the given colour, followed by `\r\n`.
fn line(colour: style::Color, text: impl AsRef<str>) {
    let _ = execute!(
        stdout(),
        style::SetForegroundColor(colour),
        style::Print(text.as_ref()),
        style::ResetColor,
        style::Print("\r\n"),
    );
}

/// Write text (no trailing newline) in the given colour.
fn write(colour: style::Color, text: impl AsRef<str>) {
    let _ = execute!(
        stdout(),
        style::SetForegroundColor(colour),
        style::Print(text.as_ref()),
        style::ResetColor,
    );
}

/// Write text with bold attribute, followed by `\r\n`.
fn line_bold(colour: style::Color, text: impl AsRef<str>) {
    let _ = execute!(
        stdout(),
        style::SetAttribute(style::Attribute::Bold),
        style::SetForegroundColor(colour),
        style::Print(text.as_ref()),
        style::ResetColor,
        style::Print("\r\n"),
    );
}

// ---------------------------------------------------------------------------
// Header & help
// ---------------------------------------------------------------------------

fn print_header(model: &str) -> Result<()> {
    execute!(
        stdout(),
        terminal::Clear(ClearType::All),
        cursor::MoveTo(0, 0),
        style::SetForegroundColor(style::Color::White),
        style::SetAttribute(style::Attribute::Bold),
        style::Print(format!(
            "═══ IA Chat MVP ═══ Model: {} ═══ Status: IDLE ═══\r\n",
            model
        )),
        style::ResetColor,
        style::Print(format!("{}\r\n", "━".repeat(55))),
        style::Print("\r\n"),
        style::SetForegroundColor(style::Color::DarkGrey),
        style::Print("Type /help for commands.\r\n"),
        style::ResetColor,
        style::Print("\r\n"),
    )?;
    stdout().flush()?;
    Ok(())
}

const HELP_TEXT: &str = "\
Available commands:\r\n\
  /exit, /quit     Exit the application\r\n\
  /help            Show this help message\r\n\
  /clear           Clear the screen and chat context\r\n\
  /model <name>    Switch the active model (display only)\r\n";

// ---------------------------------------------------------------------------
// Status display helpers
// ---------------------------------------------------------------------------

/// Return a coloured status label + colour for each orchestrator state.
fn status_label(state: &ChatState) -> (style::Color, &'static str) {
    match state {
        ChatState::Idle => (style::Color::Green, "IDLE"),
        ChatState::Listening => (style::Color::Cyan, "LISTENING"),
        ChatState::Thinking => (style::Color::Yellow, "THINKING"),
        ChatState::Working => (style::Color::Yellow, "WORKING"),
        ChatState::Delegating => (style::Color::Magenta, "DELEGATING"),
        ChatState::Streaming => (style::Color::Cyan, "STREAMING"),
        ChatState::Error => (style::Color::Red, "ERROR"),
    }
}

/// Print a one-line status indicator (overwrites the current line).
fn show_status(state: &ChatState, extra: &str) {
    let (colour, label) = status_label(state);
    let _ = execute!(
        stdout(),
        style::SetForegroundColor(colour),
        style::SetAttribute(style::Attribute::Bold),
        style::Print(format!("\r[{}]{}", label, extra)),
        style::ResetColor,
    );
    let _ = stdout().flush();
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

#[tokio::main]
async fn main() -> Result<()> {
    // ------ initialise components -------------------------------------------
    let tokens: Vec<String> = RESPONSE_TOKENS.iter().map(|s| s.to_string()).collect();
    let llm = Arc::new(MockLlmClient::new(tokens));
    let tools = Arc::new(ToolRegistry::new());
    let orch = ChatOrchestrator::new(tools, llm, 50);
    let mut model = String::from("mock-model");

    // ------ terminal setup --------------------------------------------------
    terminal::enable_raw_mode()?;
    let mut stdout = stdout();

    // Initial screen
    print_header(&model)?;

    // We track our own message log so we can re-draw on /clear.
    // Each entry is (label_colour, label, content_colour, content).
    let mut history: Vec<(style::Color, String, style::Color, String)> = Vec::new();

    // Prompt
    let _ = write!(stdout, "> ");
    let _ = stdout.flush();

    // ------ main event loop -------------------------------------------------
    let mut input = String::new();

    loop {
        // Non-blocking check; 100 ms resolution is fine for a chat UI
        if event::poll(Duration::from_millis(100))? {
            match event::read()? {
                Event::Key(key) => match key.code {
                    // --- Ctrl+C  -------------------------------------------------
                    KeyCode::Char('c') if key.modifiers == KeyModifiers::CONTROL => {
                        break;
                    }

                    // --- printable character ------------------------------------
                    KeyCode::Char(ch) if !ch.is_control() => {
                        input.push(ch);
                        let _ = write!(stdout, "{}", ch);
                        let _ = stdout.flush();
                    }

                    // --- backspace ----------------------------------------------
                    KeyCode::Backspace => {
                        if input.pop().is_some() {
                            // Move left, space, move left again
                            let _ = write!(stdout, "\x08 \x08");
                            let _ = stdout.flush();
                        }
                    }

                    // --- Enter --------------------------------------------------
                    KeyCode::Enter => {
                        let msg = input.drain(..).collect::<String>();
                        let trimmed = msg.trim().to_string();

                        // Clear the prompt line
                        let _ = execute!(stdout, Clear(ClearType::CurrentLine));
                        let _ = write!(stdout, "\r");
                        let _ = stdout.flush();

                        if trimmed.is_empty() {
                            let _ = write!(stdout, "> ");
                            let _ = stdout.flush();
                            continue;
                        }

                        // ---- handle commands -----------------------------------
                        if trimmed.starts_with('/') {
                            let parts: Vec<&str> = trimmed.splitn(2, ' ').collect();
                            match parts[0] {
                                "/exit" | "/quit" => break,

                                "/help" => {
                                    let _ = write!(stdout, "{}", HELP_TEXT);
                                }

                                "/clear" => {
                                    orch.clear_context().await;
                                    orch.force_idle().await;
                                    history.clear();
                                    print_header(&model)?;
                                }

                                "/model" if parts.len() > 1 => {
                                    model = parts[1].to_string();
                                    line(style::Color::Green, format!(
                                        "Model switched to: {}",
                                        model
                                    ));
                                }

                                cmd => {
                                    line(style::Color::Red, format!(
                                        "Unknown command: {}. Type /help for available commands.",
                                        cmd
                                    ));
                                }
                            }
                            let _ = write!(stdout, "> ");
                            let _ = stdout.flush();
                            continue;
                        }

                        // ---- user message --------------------------------------
                        history.push((
                            style::Color::Cyan,
                            "User".into(),
                            style::Color::Cyan,
                            trimmed.clone(),
                        ));

                        // Re-draw user message on the cleared prompt line
                        line_bold(style::Color::Cyan, "[User]");
                        line(style::Color::Cyan, &trimmed);
                        let _ = write!(stdout, "\r\n");

                        // ---- show status progression (artificial delays) -------
                        show_status(&ChatState::Listening, "  ");
                        sleep(Duration::from_millis(200)).await;

                        show_status(&ChatState::Thinking, "  ");
                        sleep(Duration::from_millis(250)).await;

                        show_status(&ChatState::Working, "   ");
                        sleep(Duration::from_millis(250)).await;

                        // ---- send to orchestrator ------------------------------
                        let result = orch.send_message(trimmed).await;

                        // ---- stream the response back --------------------------
                        match result {
                            Ok(response_tokens) => {
                                show_status(&ChatState::Streaming, "\r\n");
                                let _ = stdout.flush();

                                // Print the assistant label
                                line_bold(style::Color::Yellow, "[Assistant]");

                                // Stream tokens one-by-one
                                let mut full = String::new();
                                for token in &response_tokens {
                                    write(style::Color::White, token);
                                    let _ = stdout.flush();
                                    full.push_str(token);
                                    sleep(Duration::from_millis(35)).await;
                                }
                                let _ = write!(stdout, "\r\n");
                                let _ = stdout.flush();

                                history.push((
                                    style::Color::Yellow,
                                    "Assistant".into(),
                                    style::Color::White,
                                    full,
                                ));
                            }
                            Err(e) => {
                                line(style::Color::Red, format!("Error: {}", e));
                                history.push((
                                    style::Color::Red,
                                    "Error".into(),
                                    style::Color::Red,
                                    e.to_string(),
                                ));
                            }
                        }

                        // ---- back to idle --------------------------------------
                        let _ = write!(stdout, "\r\n");
                        let _ = write!(stdout, "> ");
                        let _ = stdout.flush();
                    }

                    // ---- silently ignore everything else -----------------------
                    _ => {}
                },

                // ---- ignore non-key events (mouse, resize, etc.) --------------
                _ => {}
            }
        }
    }

    // ------ cleanup ----------------------------------------------------------
    terminal::disable_raw_mode()?;
    execute!(
        stdout,
        terminal::Clear(ClearType::CurrentLine),
        cursor::MoveTo(0, 0),
        style::ResetColor,
        style::Print("\r\nGoodbye!\r\n"),
    )?;
    stdout.flush()?;

    Ok(())
}
