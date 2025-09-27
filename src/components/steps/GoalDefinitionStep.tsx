import { useState, useEffect } from "react";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import KeywordChips from "@/components/KeywordChips";
import StepContainer from "@/components/StepContainer";
import { goalKeywords } from "@/data/keywords";

interface GoalDefinitionStepProps {
  value: string;
  onChange: (value: string) => void;
  onNext: () => void;
  onPrevious: () => void;
}

const GoalDefinitionStep = ({ value, onChange, onNext, onPrevious }: GoalDefinitionStepProps) => {
  const [localValue, setLocalValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      onChange(localValue);
    }, 500);

    return () => clearTimeout(timer);
  }, [localValue, onChange]);

  const handleKeywordSelect = (keyword: string) => {
    setLocalValue(prev => {
      if (prev.trim()) {
        return `${prev.trim()} ${keyword}`;
      }
      return keyword;
    });
  };

  const isValid = localValue.trim().length > 10;

  return (
    <StepContainer
      currentStep={0}
      totalSteps={3}
      onNext={onNext}
      onPrevious={onPrevious}
      nextDisabled={!isValid}
      showPrevious={false}
      title="내가 되고 싶은 나 ✍️"
      subtitle="한 문장으로 나의 핵심 목표를 정의해보세요"
    >
      <div className="space-y-6">
        <div className="space-y-2">
          <Label htmlFor="goal-text" className="text-base font-medium">
            나는 어떤 사람이 되고 싶나요?
          </Label>
          <Textarea
            id="goal-text"
            placeholder="예: 건강하고 창의적인 일을 통해 사람들에게 도움이 되는 사람"
            value={localValue}
            onChange={(e) => setLocalValue(e.target.value)}
            className="min-h-32 text-lg p-4 border-2 focus:border-primary/50 transition-smooth resize-none"
            maxLength={200}
          />
          <div className="text-right text-sm text-muted-foreground">
            {localValue.length}/200
          </div>
        </div>

        <div className="space-y-3">
          <Label className="text-sm font-medium text-muted-foreground">
            💡 키워드 추천 (클릭하여 추가)
          </Label>
          <KeywordChips
            suggestions={goalKeywords}
            onSelect={handleKeywordSelect}
          />
        </div>

        {localValue.trim().length > 0 && localValue.trim().length < 10 && (
          <p className="text-sm text-muted-foreground bg-muted/50 p-3 rounded-lg">
            더 구체적으로 작성해주세요 (최소 10자 이상)
          </p>
        )}
      </div>
    </StepContainer>
  );
};

export default GoalDefinitionStep;