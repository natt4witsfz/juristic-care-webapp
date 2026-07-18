export interface AiRecommendationDraft {
  readonly sourceReferences: readonly string[];
  readonly recommendation: string;
  readonly assumptions: readonly string[];
  readonly limitations: readonly string[];
  readonly confidence: number;
}

export interface AiMirror {
  compareContext(
    sourceReferences: readonly string[],
    context: string,
  ): Promise<AiRecommendationDraft>;
}

export const localAiMirror: AiMirror = {
  async compareContext(sourceReferences, context) {
    return {
      sourceReferences,
      recommendation: `Human review required. Context supplied for comparison contains ${context.length} characters.`,
      assumptions: ['The supplied references are complete enough to compare.'],
      limitations: [
        'Local boundary does not call an external model.',
        'It cannot verify evidence or change authoritative records.',
      ],
      confidence: 0,
    };
  },
};
