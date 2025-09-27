import { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card } from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import KeywordChips from "@/components/KeywordChips";
import StepContainer from "@/components/StepContainer";
import { actionKeywords } from "@/data/keywords";
import { ActionItem } from "@/types/mandalart";
import { Eye } from "lucide-react";

interface ActionItemsStepProps {
  goalText: string;
  themes: string[];
  actionItems: ActionItem[];
  onChange: (actionItems: ActionItem[]) => void;
  onNext: () => void;
  onPrevious: () => void;
  onViewMandalart: () => void;
}

const ActionItemsStep = ({ 
  goalText, 
  themes, 
  actionItems, 
  onChange, 
  onNext, 
  onPrevious, 
  onViewMandalart 
}: ActionItemsStepProps) => {
  const [localActionItems, setLocalActionItems] = useState(actionItems);
  const [activeTab, setActiveTab] = useState("0");

  useEffect(() => {
    const timer = setTimeout(() => {
      onChange(localActionItems);
    }, 500);

    return () => clearTimeout(timer);
  }, [localActionItems, onChange]);

  const getThemeActions = (themeIndex: number) => {
    return localActionItems.filter(item => parseInt(item.themeId) === themeIndex);
  };

  const updateActionItem = (themeIndex: number, actionIndex: number, field: keyof ActionItem, value: any) => {
    setLocalActionItems(prev => {
      const newItems = [...prev];
      const itemIndex = newItems.findIndex(
        item => parseInt(item.themeId) === themeIndex && item.order === actionIndex
      );

      if (itemIndex >= 0) {
        newItems[itemIndex] = { ...newItems[itemIndex], [field]: value, updatedAt: new Date() };
      } else {
        // Create new action item
        const newItem: ActionItem = {
          id: `${themeIndex}-${actionIndex}`,
          themeId: themeIndex.toString(),
          actionText: field === 'actionText' ? value : "",
          isCompleted: field === 'isCompleted' ? value : false,
          order: actionIndex,
          createdAt: new Date(),
          updatedAt: new Date(),
        };
        newItems.push(newItem);
      }

      return newItems;
    });
  };

  const handleKeywordSelect = (keyword: string) => {
    const themeIndex = parseInt(activeTab);
    const themeActions = getThemeActions(themeIndex);
    const firstEmptyIndex = Array.from({ length: 8 }, (_, i) => i).find(
      i => !themeActions.some(action => action.order === i && action.actionText.trim())
    );

    if (firstEmptyIndex !== undefined) {
      updateActionItem(themeIndex, firstEmptyIndex, 'actionText', keyword);
    }
  };

  const totalActions = localActionItems.filter(item => item.actionText.trim()).length;
  const completedActions = localActionItems.filter(item => item.isCompleted).length;
  const isComplete = totalActions >= 64; // 8 themes × 8 actions

  return (
    <StepContainer
      currentStep={2}
      totalSteps={3}
      onNext={isComplete ? onNext : undefined}
      onPrevious={onPrevious}
      nextLabel="완료"
      title="세부 액션 아이템 🎯"
      subtitle="각 테마별로 구체적인 행동 계획을 세워보세요"
    >
      <div className="space-y-6">
        {/* Goal reminder */}
        <Card className="p-4 bg-gradient-warm/10 border-primary/20">
          <Label className="text-sm font-medium text-muted-foreground">나의 목표</Label>
          <p className="text-base font-medium mt-1">{goalText}</p>
        </Card>

        {/* Progress and View Button */}
        <div className="flex justify-between items-center">
          <div className="text-sm text-muted-foreground">
            총 {totalActions}/64 액션아이템 ({completedActions}개 완료)
          </div>
          <Button 
            variant="accent" 
            size="sm" 
            onClick={onViewMandalart}
            className="gap-2"
          >
            <Eye className="w-4 h-4" />
            만다라트 보기
          </Button>
        </div>

        {/* Theme tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-4 lg:grid-cols-8">
            {themes.map((theme, index) => (
              <TabsTrigger key={index} value={index.toString()} className="text-xs">
                {theme.slice(0, 4)}...
              </TabsTrigger>
            ))}
          </TabsList>

          {themes.map((theme, themeIndex) => (
            <TabsContent key={themeIndex} value={themeIndex.toString()} className="space-y-4">
              <Card className="p-4 bg-accent/5 border-accent/20">
                <h3 className="font-semibold text-lg">{theme}</h3>
                <p className="text-sm text-muted-foreground mt-1">
                  이 영역에서 실행할 구체적인 행동들을 정의하세요
                </p>
              </Card>

              <div className="space-y-3">
                {Array.from({ length: 8 }, (_, actionIndex) => {
                  const existingAction = getThemeActions(themeIndex).find(
                    action => action.order === actionIndex
                  );
                  
                  return (
                    <div key={actionIndex} className="flex items-center gap-3 p-3 border rounded-lg hover:bg-muted/30 transition-smooth">
                      <Checkbox
                        id={`action-${themeIndex}-${actionIndex}`}
                        checked={existingAction?.isCompleted || false}
                        onCheckedChange={(checked) => 
                          updateActionItem(themeIndex, actionIndex, 'isCompleted', checked)
                        }
                        className="flex-shrink-0"
                      />
                      <Input
                        placeholder={`액션 아이템 ${actionIndex + 1}`}
                        value={existingAction?.actionText || ""}
                        onChange={(e) => 
                          updateActionItem(themeIndex, actionIndex, 'actionText', e.target.value)
                        }
                        className="border-none bg-transparent focus:bg-background transition-smooth"
                        maxLength={100}
                      />
                    </div>
                  );
                })}
              </div>

              {/* Keyword suggestions for current theme */}
              <div className="space-y-3">
                <Label className="text-sm font-medium text-muted-foreground">
                  💡 액션 키워드 추천
                </Label>
                <KeywordChips
                  suggestions={actionKeywords}
                  onSelect={handleKeywordSelect}
                />
              </div>
            </TabsContent>
          ))}
        </Tabs>
      </div>
    </StepContainer>
  );
};

export default ActionItemsStep;