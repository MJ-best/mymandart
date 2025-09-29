import { MandalartProgress } from "@/types/mandalart";
import { Progress } from "@/components/ui/progress";
import { Card } from "@/components/ui/card";
import { CheckCircle, Target, TrendingUp } from "lucide-react";

interface ProgressIndicatorProps {
  progress: MandalartProgress;
  className?: string;
}

const ProgressIndicator = ({ progress, className = "" }: ProgressIndicatorProps) => {
  const { totalThemes, completedThemes, totalActions, completedActions, completionPercentage } = progress;

  return (
    <Card className={`p-4 ${className}`}>
      <div className="space-y-4">
        <div className="flex items-center gap-2">
          <TrendingUp className="w-5 h-5 text-primary" />
          <h3 className="font-semibold">진행 상황</h3>
        </div>
        
        <div className="space-y-3">
          {/* Overall Progress */}
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium">전체 완성도</span>
              <span className="text-sm text-muted-foreground">
                {Math.round(completionPercentage)}%
              </span>
            </div>
            <Progress value={completionPercentage} className="h-2" />
          </div>

          {/* Themes Progress */}
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium flex items-center gap-1">
                <Target className="w-4 h-4" />
                테마 설정
              </span>
              <span className="text-sm text-muted-foreground">
                {completedThemes}/{totalThemes}
              </span>
            </div>
            <Progress 
              value={totalThemes > 0 ? (completedThemes / totalThemes) * 100 : 0} 
              className="h-2" 
            />
          </div>

          {/* Actions Progress */}
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium flex items-center gap-1">
                <CheckCircle className="w-4 h-4" />
                액션 아이템
              </span>
              <span className="text-sm text-muted-foreground">
                {completedActions}/{totalActions}
              </span>
            </div>
            <Progress 
              value={totalActions > 0 ? (completedActions / totalActions) * 100 : 0} 
              className="h-2" 
            />
          </div>
        </div>

        {/* Completion Status */}
        {completionPercentage === 100 && (
          <div className="bg-green-50 border border-green-200 rounded-lg p-3 mt-4">
            <div className="flex items-center gap-2">
              <CheckCircle className="w-5 h-5 text-green-600" />
              <span className="text-sm font-medium text-green-800">
                🎉 축하합니다! 만다라트가 완성되었습니다!
              </span>
            </div>
          </div>
        )}
      </div>
    </Card>
  );
};

export default ProgressIndicator;