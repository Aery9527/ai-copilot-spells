# Office Documents

## Purpose

Use this file to route Office-document and document-adjacent requests inside the Anthropic skill catalog.

## Trigger Conditions

- The task involves PDF, Word, PowerPoint, or Excel files.
- The task involves creating supporting visuals for Office documents.

## Skill Mapping

- If the user wants PDF reading, merging, splitting, OCR, or creation, read [pdf](../skills/pdf/SKILL.md).
- If the user wants Word or `.docx` creation, editing, or reading, read [docx](../skills/docx/SKILL.md).
- If the user wants PowerPoint or `.pptx` creation, editing, or reading, read [pptx](../skills/pptx/SKILL.md).
- If the user wants Excel, `.xlsx`, or spreadsheet manipulation, read [xlsx](../skills/xlsx/SKILL.md).
- If the user wants static design visuals for Office documents, read [canvas-design](../skills/canvas-design/SKILL.md).
- If the user wants generative-art visuals for Office documents, read [algorithmic-art](../skills/algorithmic-art/SKILL.md).

## Decision Logic

- If the primary deliverable is a document file, choose the matching document skill first.
- If the document already exists and the user wants embedded or companion visuals, add `canvas-design` or `algorithmic-art` only after the document skill is chosen.
