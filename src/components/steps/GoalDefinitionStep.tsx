import { useState, useEffect } from "react";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import KeywordChips from "@/components/KeywordChips";
import StepContainer from "@/components/StepContainer";
import { goalKeywords, goalTemplates } from "@/data/keywords";
import { Lightbulb, Target } from "lucide-react";

interface GoalDefinitionStepProps {
  value: string;
  onChange: (value: string) => void;
  onNext: () => void;
  onPrevious: () => void;
}

const GoalDefinitionStep = ({ value, onChange, onNext, onPrevious }: GoalDefinitionStepProps) => {
  const [localValue, setLocalValue] = useState(value);
  const [showTemplates, setShowTemplates] = useState(false);

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

  const handleTemplateSelect = (template: string) => {
    setLocalValue(template);
    setShowTemplates(false);
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
        {/* Template suggestions */}
        <Card className="p-4 bg-gradient-warm/5 border-primary/10">
          <div className="flex items-center gap-2 mb-3">
            <Lightbulb className="w-4 h-4 text-primary" />
            <Label className="text-sm font-medium text-muted-foreground">
              템플릿으로 시작하기
            </Label>
          </div>
          <div className="flex flex-wrap gap-2">
            {goalTemplates.map((template, index) => (
              <Button
                key={index}
                variant="outline"
                size="sm"
                onClick={() => handleTemplateSelect(template)}
                className="text-xs hover:bg-primary/10"
              >
                {template}
              </Button>
            ))}
          </div>
        </Card>

        <div className="space-y-2">
          <Label htmlFor="goal-text" className="text-base font-medium flex items-center gap-2">
            <Target className="w-4 h-4" />
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
            maxItems={8}
          />
        </div>

        {localValue.trim().length > 0 && localValue.trim().length < 10 && (
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
            <p className="text-sm text-amber-800">
              💡 더 구체적으로 작성해주세요 (최소 10자 이상)
            </p>
          </div>
        )}

        {isValid && (
          <div className="bg-green-50 border border-green-200 rounded-lg p-3">
            <p className="text-sm text-green-800">
              ✅ 좋습니다! 이제 다음 단계로 진행할 수 있습니다.
            </p>
          </div>
        )}
      </div>
    </StepContainer>
  );
};

export default GoalDefinitionStep;