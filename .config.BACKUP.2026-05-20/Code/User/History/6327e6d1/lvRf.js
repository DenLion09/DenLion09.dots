import Image from "next/image";
import { Text, Btn } from "./atoms";

const GITHUB_USERNAME = "DenLion09";

export default function Hero() {
  return (
    <div className="flex flex-col justify-between h-full gap-6">
      {/* Avatar */}
      <div className="flex-shrink-0 flex justify-center">
        <div
          className="relative w-32 h-32 rounded-full overflow-hidden border-2 shadow-sm"
          style={{ borderColor: "var(--color-border)" }}
        >
          <Image
            src={`https://avatars.githubusercontent.com/u/112094601?`}
            alt={`Avatar de ${GITHUB_USERNAME}`}
            fill
            className="object-cover"
            sizes="128px"
          />
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-start justify-center space-y-4">
        <Text variant="h1">Hola, soy Diorges</Text>

        <Text variant="body">
          Full Stack Developer con pasión por crear soluciones elegantes.
        </Text>

        <div className="space-y-3 pt-2">
          <Text variant="xs" as="h2" style={{ color: "var(--color-accent)" }}>
            Sobre mí
          </Text>

          <ul
            className="space-y-2 text-sm"
            style={{ color: "var(--color-secondary-text)" }}
          >
            <li className="flex items-center gap-2">
              <span style={{ color: "var(--color-accent)" }}>▸</span>
              15+ años de experiencia en desarrollo
            </li>
            <li className="flex items-center gap-2">
              <span style={{ color: "var(--color-accent)" }}>▸</span>
              Especializado en React, Node.js, Go
            </li>
            <li className="flex items-center gap-2">
              <span style={{ color: "var(--color-accent)" }}>▸</span>
              Google Developer Expert
            </li>
            <li className="flex items-center gap-2">
              <span style={{ color: "var(--color-accent)" }}>▸</span>
              Microsoft MVP
            </li>
          </ul>

          <Text variant="small">
            Me apasiona construir soluciones que{" "}
            <span
              className="font-semibold"
              style={{ color: "var(--color-primary-text)" }}
            >
              marcan la diferencia
            </span>
            . Creo software que no solo funciona, sino que{" "}
            <span
              className="font-semibold"
              style={{ color: "var(--color-primary-text)" }}
            >
              inspira confianza
            </span>
            . Cuando no estoy programando, estoy explorando nuevas tecnologías y
            compartiendo conocimiento con la comunidad.
          </Text>

          <div>
            <Btn icon="contactame!">icon</Btn>
          </div>
        </div>
      </div>
    </div>
  );
}
