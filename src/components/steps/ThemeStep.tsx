import { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import KeywordChips from "@/components/KeywordChips";
import StepContainer from "@/components/StepContainer";
import { themeKeywords } from "@/data/keywords";

interface ThemeStepProps {
  goalText: string;
  themes: string[];
  onChange: (themes: string[]) => void;
  onNext: () => void;
  onPrevious: () => void;
}

const ThemeStep = ({ goalText, themes, onChange, onNext, onPrevious }: ThemeStepProps) => {
  const [localThemes, setLocalThemes] = useState(themes);

  useEffect(() => {
    const timer = setTimeout(() => {
      onChange(localThemes);
    }, 500);

    return () => clearTimeout(timer);
  }, [localThemes, onChange]);

  const handleThemeChange = (index: number, value: string) => {
    const newThemes = [...localThemes];
    newThemes[index] = value;
    setLocalThemes(newThemes);
  };

  const handleKeywordSelect = (keyword: string, index: number) => {
    handleThemeChange(index, keyword);
  };

  const filledThemes = localThemes.filter(theme => theme.trim().length > 0);
  const isValid = filledThemes.length === 8;

  return (
    <StepContainer
      currentStep={1}
      totalSteps={3}
      onNext={onNext}
      onPrevious={onPrevious}
      nextDisabled={!isValid}
      title="8가지 핵심 테마 💡"
      subtitle="목표 달성을 위한 핵심 영역들을 정의해보세요"
    >
      <div className="space-y-6">
        {/* Goal reminder */}
        <Card className="p-4 bg-gradient-warm/10 border-primary/20">
          <Label className="text-sm font-medium text-muted-foreground">나의 목표</Label>
          <p className="text-lg font-medium mt-1">{goalText}</p>
        </Card>

        {/* Theme inputs */}
        <div className="grid gap-4">
          {Array.from({ length: 8 }, (_, index) => (
            <div key={index} className="space-y-2">
              <Label className="text-sm font-medium">
                테마 {index + 1}
              </Label>
              <Input
                value={localThemes[index] || ""}
                onChange={(e) => handleThemeChange(index, e.target.value)}
                placeholder={`${index + 1}번째 핵심 영역을 입력하세요`}
                className="text-base p-3 border-2 focus:border-primary/50 transition-smooth"
                maxLength={50}
              />
            </div>
          ))}
        </div>

        {/* Keyword suggestions */}
        <div className="space-y-3">
          <Label className="text-sm font-medium text-muted-foreground">
            💡 테마 키워드 추천
          </Label>
          <KeywordChips
            suggestions={themeKeywords}
            onSelect={(keyword) => {
              // Find first empty theme slot
              const firstEmptyIndex = localThemes.findIndex(theme => !theme.trim());
              if (firstEmptyIndex !== -1) {
                handleKeywordSelect(keyword, firstEmptyIndex);
              }
            }}
          />
        </div>

        {/* Progress indicator */}
        <div className="bg-muted/50 p-4 rounded-lg">
          <div className="flex justify-between items-center">
            <span className="text-sm font-medium">진행률</span>
            <span className="text-sm text-muted-foreground">
              {filledThemes.length}/8 완료
            </span>
          </div>
          <div className="mt-2 bg-background rounded-full h-2">
            <div 
              className="bg-gradient-primary h-2 rounded-full transition-smooth"
              style={{ width: `${(filledThemes.length / 8) * 100}%` }}
            />
          </div>
        </div>
      </div>
    </StepContainer>
  );
};

export default ThemeStep;