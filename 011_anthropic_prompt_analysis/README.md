# prompt système de claude dans chrome — traduction française

ce dossier contient la traduction française du prompt système complet de Claude tel qu'il est injecté dans le navigateur Chrome (version extraite et analysée dans l'article Snow Viber).

## ce que vous trouverez ici

**`code/Claude_prompt_system_FR.md`** — traduction complète (~600 lignes) du prompt système original anglais d'Anthropic. le document couvre :

- l'identité et les instructions générales du modèle
- les mécanismes anti-injection de prompt (la moitié du fichier)
- les garde-fous sur les sujets sensibles (politique, violence, contenus adultes)
- les règles de formatage et de ton
- les faits injectés manuellement (dont l'élection présidentielle américaine de 2024)

## contexte

le prompt système est le texte qu'anthropic injecte **avant votre premier message**. vous ne le voyez jamais. il définit qui est le modèle, ce qu'il peut faire, et comment il réagit face aux situations sensibles.

dans le cas de Claude dans Chrome, ce prompt fait environ 15 000 mots. c'est la taille d'une nouvelle de maupassant.

la traduction ici est fournie à titre éducatif et d'analyse. le prompt original est en anglais.

---

_analyse complète dans l'article Snow Viber. code propulsé par [SnowflakeViber](https://snowflakeviber.substack.com) — l'excellence Snowflake, sans le bullshit._
