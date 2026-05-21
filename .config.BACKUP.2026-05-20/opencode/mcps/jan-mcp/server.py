#!/usr/bin/env python3
"""
MCP server for jan-cli - Local LLM inference management.

Exposes jan-cli functionality via the Model Context Protocol (MCP).
"""

import subprocess
import json
import os
import sys
import signal
import re
from pathlib import Path

# Configuration
JAN_CLI_PATH = "/usr/bin/jan-cli"
DATA_DIR = os.path.expanduser("~/.jan")
SERVER_PID_FILE = os.path.expanduser("~/.jan/server.pid")
SERVER_PORT_FILE = os.path.expanduser("~/.jan/server.port")


def run_jan_cli(args: list) -> dict:
    """Run jan-cli command and return JSON output."""
    try:
        result = subprocess.run(
            ["jan-cli"] + args,
            capture_output=True,
            text=True,
            timeout=60
        )
        return {
            "success": True,
            "stdout": result.stdout,
            "stderr": result.stderr,
            "returncode": result.returncode
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "error": "Command timed out"}
    except Exception as e:
        return {"success": False, "error": str(e)}


def get_running_pid() -> int | None:
    """Get the PID of the running server."""
    try:
        if os.path.exists(SERVER_PID_FILE):
            with open(SERVER_PID_FILE) as f:
                return int(f.read().strip())
    except:
        pass
    return None


def get_running_port() -> int | None:
    """Get the port of the running server."""
    try:
        if os.path.exists(SERVER_PORT_FILE):
            with open(SERVER_PORT_FILE) as f:
                return int(f.read().strip())
    except:
        pass
    return None


def is_server_running(pid: int) -> bool:
    """Check if a process is running."""
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def list_models() -> dict:
    """List all installed models."""
    result = run_jan_cli(["models", "list"])
    if result.get("success") and result.get("stdout"):
        try:
            models = json.loads(result["stdout"])
            return {"success": True, "models": models}
        except json.JSONDecodeError:
            return {"success": True, "raw": result["stdout"]}
    return result


def start_server(model_id: str = None, port: int = 6767, detach: bool = True, **kwargs) -> dict:
    """Start the jan-cli server with a model."""
    # Check if already running
    pid = get_running_pid()
    if pid and is_server_running(pid):
        running_port = get_running_port()
        return {
            "success": False,
            "error": f"Server already running on port {running_port}",
            "pid": pid,
            "port": running_port
        }

    args = ["serve"]
    if model_id:
        args.append(model_id)
    args.extend(["--port", str(port)])
    if detach:
        args.append("--detach")
    if kwargs.get("verbose"):
        args.append("--verbose")
    if kwargs.get("fit"):
        args.append("--fit")
    if kwargs.get("n_gpu_layers"):
        args.extend(["--n-gpu-layers", str(kwargs["n_gpu_layers"])])
    if kwargs.get("ctx_size"):
        args.extend(["--ctx-size", str(kwargs["ctx_size"])])
    if kwargs.get("threads"):
        args.extend(["--threads", str(kwargs["threads"])])
    if kwargs.get("api_key"):
        args.extend(["--api-key", kwargs["api_key"]])

    result = run_jan_cli(args)
    
    if result.get("success"):
        # Give it a moment to start, then verify
        import time
        time.sleep(2)
        
        # Try to get the port from background process
        new_pid = get_running_pid()
        new_port = get_running_port()
        
        return {
            "success": True,
            "message": f"Server started on port {new_port or port}",
            "pid": new_pid,
            "port": new_port or port
        }
    
    return result


def stop_server() -> dict:
    """Stop the running server."""
    pid = get_running_pid()
    if not pid or not is_server_running(pid):
        return {"success": False, "error": "No server running"}
    
    try:
        os.kill(pid, signal.SIGTERM)
        # Wait for process to stop
        import time
        for _ in range(10):
            if not is_server_running(pid):
                break
            time.sleep(0.5)
        
        # Cleanup files
        if os.path.exists(SERVER_PID_FILE):
            os.remove(SERVER_PID_FILE)
        if os.path.exists(SERVER_PORT_FILE):
            os.remove(SERVER_PORT_FILE)
            
        return {"success": True, "message": f"Server stopped (PID: {pid})"}
    except Exception as e:
        return {"success": False, "error": str(e)}


def get_status() -> dict:
    """Get server status."""
    pid = get_running_pid()
    port = get_running_port()
    
    if pid and is_server_running(pid):
        return {
            "running": True,
            "pid": pid,
            "port": port
        }
    return {"running": False}


# MCP Tools
TOOLS = [
    {
        "name": "jan_list_models",
        "description": "List all models installed in the Jan data folder",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    },
    {
        "name": "jan_start_server",
        "description": "Start the jan-cli server with a model",
        "inputSchema": {
            "type": "object",
            "properties": {
                "model_id": {
                    "type": "string",
                    "description": "Model ID to load (omit to pick from list)"
                },
                "port": {
                    "type": "number",
                    "description": "Port to listen on (default: 6767)",
                    "default": 6767
                },
                "verbose": {
                    "type": "boolean",
                    "description": "Print full server logs",
                    "default": False
                },
                "fit": {
                    "type": "boolean",
                    "description": "Auto-fit context to available VRAM",
                    "default": False
                },
                "api_key": {
                    "type": "string",
                    "description": "API key for authentication",
                    "default": ""
                }
            }
        }
    },
    {
        "name": "jan_stop_server",
        "description": "Stop the running jan-cli server",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    },
    {
        "name": "jan_status",
        "description": "Get the status of the jan-cli server (running or stopped)",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    }
]


def handle_tool(name: str, arguments: dict = None) -> dict:
    """Handle tool calls."""
    arguments = arguments or {}
    
    if name == "jan_list_models":
        return list_models()
    elif name == "jan_start_server":
        return start_server(**arguments)
    elif name == "jan_stop_server":
        return stop_server()
    elif name == "jan_status":
        return get_status()
    else:
        return {"error": f"Unknown tool: {name}"}


def main():
    """Main MCP server loop."""
    # Simple JSON-RPC over stdio
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            
            request = json.loads(line.strip())
            method = request.get("method")
            msg_id = request.get("id")
            
            if method == "initialize":
                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {
                        "protocolVersion": "2024-11-05",
                        "capabilities": {"tools": {}},
                        "serverInfo": {"name": "jan-mcp", "version": "1.0.0"}
                    }
                }
                print(json.dumps(response), flush=True)
                
            elif method == "tools/list":
                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {"tools": TOOLS}
                }
                print(json.dumps(response), flush=True)
                
            elif method == "tools/call":
                args = request.get("params", {}).get("arguments", {})
                name = request.get("params", {}).get("name")
                result = handle_tool(name, args)
                
                response = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {"content": [{"type": "text", "text": json.dumps(result)}]}
                }
                print(json.dumps(response), flush=True)
                
        except EOFError:
            break
        except Exception as e:
            error_response = {
                "jsonrpc": "2.0",
                "id": msg_id if 'msg_id' in locals() else None,
                "error": {"message": str(e)}
            }
            print(json.dumps(error_response), flush=True)


if __name__ == "__main__":
    main()