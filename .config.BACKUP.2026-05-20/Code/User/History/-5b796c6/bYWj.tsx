import { useState, useEffect } from "react";
import type { Operator, CalculatorState } from "./types/calculator";
import {
  evaluateExpression,
  createMemoryEntry,
  addToMemory,
  getMemoryResult,
  wouldOverflow,
} from "./utils/calculatorEngine";
import "./App.css";

const initialState: CalculatorState = {
  display: "0",
  previousOperand: null,
  operator: null,
  memory: [],
  justCalculated: false,
};

function App() {
  const [state, setState] = useState<CalculatorState>(initialState);
  const { display, previousOperand, operator, memory, justCalculated } = state;

  // Keyboard support
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      const key = e.key;

      if (key >= "0" && key <= "9") {
        handleDigit(key);
      } else if (key === ".") {
        handleDigit(".");
      } else if (key === "+" || key === "-") {
        handleOperator(key);
      } else if (key === "*") {
        handleOperator("×");
      } else if (key === "/") {
        e.preventDefault(); // Prevent browser's quick find
        handleOperator("÷");
      } else if (key === "Enter" || key === "=") {
        handleEquals();
      } else if (key === "Escape") {
        handleAllClear();
      } else if (key === "Backspace") {
        handleDelete();
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [display, previousOperand, operator, memory, justCalculated]);

  const handleDigit = (digit: string) => {
    if (display === "Error") {
      setState({ ...initialState, display: digit });
      return;
    }

    if (justCalculated) {
      setState({ ...state, display: digit, justCalculated: false });
      return;
    }

    // Handle decimal point
    if (digit === ".") {
      if (display.includes(".")) return;
      setState({ ...state, display: display + ".", justCalculated: false });
      return;
    }

    // Limit digits
    if (display.replace(".", "").length >= 15) return;

    const newDisplay =
      display === "0" && digit !== "." ? digit : display + digit;
    setState({ ...state, display: newDisplay, justCalculated: false });
  };

  const handleOperator = (newOperator: Operator) => {
    if (display === "Error") return;

    // Check overflow before operation
    if (wouldOverflow(display)) {
      setState({ ...state, display: "Error" });
      return;
    }

    if (previousOperand !== null && operator !== null) {
      // There's a pending operation - calculate first
      const expression = `${previousOperand} ${operator} ${display}`;
      const result = evaluateExpression(expression);

      if (result === "Error") {
        setState({
          ...state,
          display: "Error",
          previousOperand: null,
          operator: null,
        });
        return;
      }

      // Save to memory
      const memoryEntry = createMemoryEntry(
        `${previousOperand} ${operator} ${display}`,
        result,
      );
      const newMemory = addToMemory(memory, memoryEntry);
      setState({
        ...state,
        display: result,
        previousOperand: result,
        operator: newOperator,
        memory: newMemory,
        justCalculated: true,
      });
    } else {
      setState({
        ...state,
        previousOperand: display,
        operator: newOperator,
        justCalculated: true,
      });
    }
  };

  const handleEquals = () => {
    if (previousOperand === null || operator === null) {
      // Just show current value
      return;
    }

    if (display === "Error") return;

    // Check overflow before operation
    if (wouldOverflow(display)) {
      setState({ ...state, display: "Error" });
      return;
    }

    const expression = `${previousOperand} ${operator} ${display}`;
    const result = evaluateExpression(expression);

    // Save to memory
    const memoryEntry = createMemoryEntry(expression, result);
    const newMemory = addToMemory(memory, memoryEntry);

    setState({
      ...state,
      display: result,
      previousOperand: null,
      operator: null,
      memory: newMemory,
      justCalculated: true,
    });
  };

  const handleClear = () => {
    // Clear only current operand
    setState({ ...state, display: "0" });
  };

  const handleAllClear = () => {
    setState(initialState);
  };

  const handleDelete = () => {
    if (justCalculated) return;

    if (display === "Error") {
      setState({ ...state, display: "0" });
      return;
    }

    const newDisplay = display.slice(0, -1);
    setState({ ...state, display: newDisplay === "" ? "0" : newDisplay });
  };

  const handleMemoryRecall = (index: number) => {
    const result = getMemoryResult(memory, index);
    if (result !== null) {
      setState({ ...state, display: result, justCalculated: true });
    }
  };

  const handleButtonClick = (value: string) => {
    if (value >= "0" && value <= "9") {
      handleDigit(value);
    } else if (value === ".") {
      handleDigit(value);
    } else if (
      value === "+" ||
      value === "-" ||
      value === "×" ||
      value === "÷"
    ) {
      handleOperator(value);
    } else if (value === "=") {
      handleEquals();
    } else if (value === "C") {
      handleClear();
    } else if (value === "AC") {
      handleAllClear();
    } else if (value === "DEL") {
      handleDelete();
    }
  };

  return (
    <div className="calculator">
      <div className="display">
        <div className="display-value">{display}</div>
      </div>

      {memory.length > 0 && (
        <div className="memory-panel">
          {memory.map((entry, index) => (
            <button
              key={index}
              className="memory-button"
              onClick={() => handleMemoryRecall(index)}
            >
              {entry.result}
            </button>
          ))}
        </div>
      )}

      <div className="keypad">
        <div className="row">
          <button
            className="button function"
            onClick={() => handleButtonClick("AC")}
          >
            AC
          </button>
          <button
            className="button function"
            onClick={() => handleButtonClick("C")}
          >
            C
          </button>
          <button
            className="button function"
            onClick={() => handleButtonClick("DEL")}
          >
            <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
              <path d="M22 3H7c-.69 0-1.23.35-1.59.88L2 12l3.41 5.12c.36.53.9.88 1.59.88h15c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H7.07L5.12 12.03l-.03-.03L7.07 7H22v12zm-11.59-2.59L9.41 15 12 17.59l2.59-2.59L16 13.59l-2.59 2.59L16 18.77l-2.59-2.59L12 14.77l-1.59-1.59L9 14.41l2.59-2.59L9 9.23l2.59-2.59L12 8.18l1.41-1.41 1.59 1.59-1.59 1.59 1.59 2.59-2.59 1.59z" />
            </svg>
          </button>
          <button
            className="button operator"
            onClick={() => handleButtonClick("÷")}
          >
            ÷
          </button>
        </div>
        <div className="row">
          <button
            className="button digit"
            onClick={() => handleButtonClick("7")}
          >
            7
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick("8")}
          >
            8
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick("9")}
          >
            9
          </button>
          <button
            className="button operator"
            onClick={() => handleButtonClick("×")}
          >
            ×
          </button>
        </div>
        <div className="row">
          <button
            className="button digit"
            onClick={() => handleButtonClick("4")}
          >
            4
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick("5")}
          >
            5
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick("6")}
          >
            6
          </button>
          <button
            className="button operator"
            onClick={() => handleButtonClick("-")}
          >
            −
          </button>
        </div>
        <div className="row">
          <button
            className="button digit"
            onClick={() => handleButtonClick("1")}
          >
            1
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick("2")}
          >
            2
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick("3")}
          >
            3
          </button>
          <button
            className="button operator"
            onClick={() => handleButtonClick("+")}
          >
            +
          </button>
        </div>
        <div className="row">
          <button
            className="button digit zero"
            onClick={() => handleButtonClick("0")}
          >
            0
          </button>
          <button
            className="button digit"
            onClick={() => handleButtonClick(".")}
          >
            .
          </button>
          <button
            className="button equals"
            onClick={() => handleButtonClick("=")}
          >
            =
          </button>
        </div>
      </div>
    </div>
  );
}

export default App;
