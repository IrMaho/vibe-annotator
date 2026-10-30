enum PromptTemplateType {
  vibeCodingStandard('Agent Vibe-Coding (Standard)', 'Comprehensive instructions with location hints and bounding boxes'),
  compactVision('Compact Spatial Vision (Gemini / Claude)', 'Token-efficient bbox list directly linked to labels'),
  checklist('Task Checklist', 'Step-by-step checklist formatted for agents to check off'),
  json('Raw JSON Payload', 'Structured JSON data for automated pipelines');

  final String title;
  final String description;
  const PromptTemplateType(this.title, this.description);
}
