"use client";

import { useState, useRef } from "react";
import emailjs from "@emailjs/browser";
import { X, Mail, Linkedin, Github, Send, AlertCircle } from "lucide-react";

// Configuración de EmailJS - REEMPLAZAR con tus valores reales
// Obtén tus credenciales en: https://dashboard.emailjs.com
const EMAILJS_CONFIG = {
  serviceId: "service_corr7qp", // ej: "service_xxxxxx"
  templateId: "YOUR_TEMPLATE_ID", // ej: "template_xxxxxx"
  publicKey: "YOUR_PUBLIC_KEY", // ej: "xxxxxxxxxxxxxxxxxx"
};

const SOCIAL_LINKS_BASE = {
  linkedin: "https://linkedin.com/in/diorges",
  github: "https://github.com/DenLion09",
};

export function ContactModal({ ownerEmail }) {
  const formRef = useRef(null);
  const [isOpen, setIsOpen] = useState(false);
  const [formState, setFormState] = useState({
    name: "",
    email: "",
    message: "",
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [error, setError] = useState(null);

  // Social links dinámico basado en el email del owner desde GitHub
  const socialLinks = {
    ...SOCIAL_LINKS_BASE,
    email: ownerEmail ? `mailto:${ownerEmail}` : null,
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError(null);

    try {
      // Usar EmailJS para enviar el email
      const response = await emailjs.sendForm(
        EMAILJS_CONFIG.serviceId,
        EMAILJS_CONFIG.templateId,
        formRef.current,
        EMAILJS_CONFIG.publicKey,
      );

      if (response.status === 200) {
        setIsSubmitted(true);
        // Reset después de 3 segundos
        setTimeout(() => {
          setIsSubmitted(false);
          setFormState({ name: "", email: "", message: "" });
        }, 3000);
      }
    } catch (err) {
      console.error("EmailJS Error:", err);
      setError("Error al enviar el mensaje. Por favor intenta de nuevo.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormState((prev) => ({ ...prev, [name]: value }));
    setError(null);
  };

  const closeModal = () => {
    setIsOpen(false);
    setError(null);
    setIsSubmitted(false);
  };

  if (!isOpen) {
    return (
      <button
        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm cursor-pointer transition-all hover:opacity-80"
        style={{
          background: "var(--color-background)",
          border: "1px solid var(--color-border)",
          color: "var(--color-secondary-text)",
        }}
        onClick={() => setIsOpen(true)}
      >
        <Mail size={14} />
        Contáctame
      </button>
    );
  }

  return (
    <>
      {/* Backdrop - oscurece toda la pantalla */}
      <div
        className="fixed inset-0 z-40 animate-fade-in"
        style={{
          backgroundColor: "rgba(0, 0, 0, 0.6)",
        }}
        onClick={closeModal}
      />

      {/* Modal - centrado exactamente en pantalla */}
      <div
        className="fixed z-50 animate-scale-in"
        style={{
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: "min(90vw, 420px)",
          maxWidth: "420px",
          background: "var(--color-surface)",
          border: "1px solid var(--color-border)",
          borderRadius: "12px",
          padding: "1.5rem",
          boxShadow: "0 25px 50px -12px rgba(0, 0, 0, 0.4)",
        }}
      >
        {/* Header */}
        <div className="flex items-center justify-between mb-6">
          <h3
            className="text-lg font-semibold"
            style={{ color: "var(--color-primary-text)" }}
          >
            Contáctame
          </h3>
          <button
            onClick={closeModal}
            className="p-1 rounded-md transition-colors cursor-pointer"
            style={{
              color: "var(--color-secondary-text)",
            }}
            aria-label="Cerrar"
          >
            <X size={20} />
          </button>
        </div>

        {/* Formulario */}
        {!isSubmitted ? (
          <form ref={formRef} onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label
                htmlFor="name"
                className="block text-sm mb-1.5"
                style={{ color: "var(--color-secondary-text)" }}
              >
                Nombre
              </label>
              <input
                type="text"
                id="name"
                name="name"
                value={formState.name}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 rounded-md text-sm outline-none transition-colors"
                style={{
                  background: "var(--color-background)",
                  border: "1px solid var(--color-border)",
                  color: "var(--color-primary-text)",
                }}
                placeholder="Tu nombre"
              />
            </div>

            <div>
              <label
                htmlFor="email"
                className="block text-sm mb-1.5"
                style={{ color: "var(--color-secondary-text)" }}
              >
                Email
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={formState.email}
                onChange={handleInputChange}
                required
                className="w-full px-3 py-2 rounded-md text-sm outline-none transition-colors"
                style={{
                  background: "var(--color-background)",
                  border: "1px solid var(--color-border)",
                  color: "var(--color-primary-text)",
                }}
                placeholder="tu@email.com"
              />
            </div>

            <div>
              <label
                htmlFor="message"
                className="block text-sm mb-1.5"
                style={{ color: "var(--color-secondary-text)" }}
              >
                Mensaje
              </label>
              <textarea
                id="message"
                name="message"
                value={formState.message}
                onChange={handleInputChange}
                required
                rows={4}
                className="w-full px-3 py-2 rounded-md text-sm outline-none transition-colors resize-none"
                style={{
                  background: "var(--color-background)",
                  border: "1px solid var(--color-border)",
                  color: "var(--color-primary-text)",
                }}
                placeholder="¿En qué puedo ayudarte?"
              />
            </div>

            {/* Error message */}
            {error && (
              <div
                className="flex items-center gap-2 p-3 rounded-md text-sm"
                style={{
                  background: "rgba(239, 68, 68, 0.1)",
                  color: "#ef4444",
                  border: "1px solid rgba(239, 68, 68, 0.3)",
                }}
              >
                <AlertCircle size={16} />
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full py-2 px-4 rounded-md text-sm font-medium flex items-center justify-center gap-2 transition-all disabled:opacity-50 cursor-pointer"
              style={{
                background: "var(--color-accent)",
                color: "#fff",
              }}
            >
              {isSubmitting ? (
                "Enviando..."
              ) : (
                <>
                  <Send size={14} />
                  Enviar mensaje
                </>
              )}
            </button>
          </form>
        ) : (
          /* Estado de éxito */
          <div className="text-center py-8">
            <div
              className="w-12 h-12 mx-auto mb-4 rounded-full flex items-center justify-center"
              style={{ background: "var(--color-accent)" }}
            >
              <Send size={24} style={{ color: "#fff" }} />
            </div>
            <h4
              className="text-lg font-semibold mb-2"
              style={{ color: "var(--color-primary-text)" }}
            >
              ¡Mensaje enviado!
            </h4>
            <p
              className="text-sm"
              style={{ color: "var(--color-secondary-text)" }}
            >
              Gracias por contactarme. Te responderé pronto.
            </p>
          </div>
        )}

        {/* Divider */}
        <div className="flex items-center gap-3 my-6">
          <div
            className="flex-1 h-px"
            style={{ background: "var(--color-border)" }}
          />
          <span
            className="text-xs"
            style={{ color: "var(--color-secondary-text)" }}
          >
            o conecta en
          </span>
          <div
            className="flex-1 h-px"
            style={{ background: "var(--color-border)" }}
          />
        </div>

        {/* Social Links */}
        <div className="flex justify-center gap-4">
          <a
            href={socialLinks.linkedin}
            target="_blank"
            rel="noopener noreferrer"
            className="p-2.5 rounded-md transition-all hover:opacity-80 cursor-pointer"
            style={{
              background: "var(--color-background)",
              border: "1px solid var(--color-border)",
              color: "var(--color-secondary-text)",
            }}
            aria-label="LinkedIn"
          >
            <Linkedin size={18} />
          </a>

          <a
            href={socialLinks.github}
            target="_blank"
            rel="noopener noreferrer"
            className="p-2.5 rounded-md transition-all hover:opacity-80 cursor-pointer"
            style={{
              background: "var(--color-background)",
              border: "1px solid var(--color-border)",
              color: "var(--color-secondary-text)",
            }}
            aria-label="GitHub"
          >
            <Github size={18} />
          </a>

          <a
            href={socialLinks.email}
            className="p-2.5 rounded-md transition-all hover:opacity-80 cursor-pointer"
            style={{
              background: "var(--color-background)",
              border: "1px solid var(--color-border)",
              color: "var(--color-secondary-text)",
            }}
            aria-label="Email"
          >
            <Mail size={18} />
          </a>
        </div>
      </div>
    </>
  );
}

export default ContactModal;
