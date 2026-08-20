<p align="center">
  <img src="https://media.licdn.com/dms/image/v2/D4D0BAQFqqkJoRRTbvg/company-logo_200_200/B4DZzUkmmOIwAI-/0/1773092891383/kxctecnologia_logo?e=2147483647&v=beta&t=ur-oxF2eamhQF4g4fDQjh6sy1lmH9W7pnOIrNAYOOzg" alt="KXC Tecnologia" width="120" />
</p>

# Simple-api

Repositório do Desafio Técnico KXC. Uma API em Node.js que conecta a um PostgreSQL, com a infraestrutura provisionada na AWS via Terraform.

## Estrutura

```
simple-api/
├── application/       # Código da aplicação (Node.js + Express)
└── infrastructure/    # Infraestrutura como código (Terraform)
```

- **`application/`** — a API e suas dependências. Detalhes de uso e variáveis de ambiente no `application/README.md`.
- **`infrastructure/`** — módulos e configuração Terraform para provisionar a solução na AWS. Detalhes no `infrastructure/README.md`.
