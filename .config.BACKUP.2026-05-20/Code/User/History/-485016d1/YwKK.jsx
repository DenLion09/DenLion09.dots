import { useEffect, useRef, useCallback } from "react";
import { createPortal } from "react-dom";

const Dialog = ({
  isOpen = false,
  onClose,
  title,
  description,
  children,
  disableEsc = false,
  disableOverlayClick = false,
  portalTarget = null,
  ...rest
}) => {
  const dialogRef = useRef(null);
  const previousFocusRef = useRef(null);

  // Guardar el elemento que tenía el focus antes de abrir el dialog
  useEffect(() => {
    if (isOpen) {
      previousFocusRef.current = document.activeElement;
      // Focus en el dialog después del render
      setTimeout(() => {
        dialogRef.current?.focus();
      }, 0);
    }
  }, [isOpen]);

  // Restaurar focus al cerrar
  useEffect(() => {
    if (!isOpen && previousFocusRef.current) {
      previousFocusRef.current.focus();
    }
  }, [isOpen]);

  // Manejar tecla ESC
  const handleKeyDown = useCallback(
    (e) => {
      if (e.key === "Escape" && !disableEsc && onClose) {
        onClose();
      }
    },
    [disableEsc, onClose],
  );

  // Click en el overlay (fuera del dialog)
  const handleOverlayClick = useCallback(
    (e) => {
      if (e.target === e.currentTarget && !disableOverlayClick && onClose) {
        onClose();
      }
    },
    [disableOverlayClick, onClose],
  );

  // No renderizar nada si no está abierto
  if (!isOpen) return null;

  const dialogContent = (
    <div
      className="dialog-overlay"
      onClick={handleOverlayClick}
      onKeyDown={handleKeyDown}
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: "rgba(0, 0, 0, 0.5)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 9999,
      }}
      {...rest}
    >
      <div
        ref={dialogRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={title ? "dialog-title" : undefined}
        aria-describedby={description ? "dialog-description" : undefined}
        tabIndex={-1}
        className="dialog-content"
        style={{
          backgroundColor: "white",
          borderRadius: "8px",
          padding: "24px",
          maxWidth: "500px",
          width: "90%",
          maxHeight: "80vh",
          overflow: "auto",
          outline: "none",
        }}
      >
        {title && (
          <h2 id="dialog-title" style={{ marginTop: 0 }}>
            {title}
          </h2>
        )}
        {description && (
          <p id="dialog-description" style={{ margin: "8px 0" }}>
            {description}
          </p>
        )}
        {children}
      </div>
    </div>
  );

  // Usar portal si está disponible, si no, renderizar inline
  if (portalTarget && createPortal) {
    return createPortal(dialogContent, portalTarget);
  }

  // Fallback: buscar #portal-root o usar document.body
  const portalRoot =
    typeof document !== "undefined"
      ? document.getElementById("portal-root") || document.body
      : null;

  if (portalRoot && createPortal) {
    return createPortal(dialogContent, portalRoot);
  }

  return dialogContent;
};

export default Dialog;
