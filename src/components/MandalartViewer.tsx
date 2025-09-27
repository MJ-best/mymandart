import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Download, Share, X } from "lucide-react";
import { MandalartData } from "@/types/mandalart";
import { cn } from "@/lib/utils";

interface MandalartViewerProps {
  data: MandalartData;
  isOpen?: boolean;
  onClose?: () => void;
}

const MandalartViewer = ({ data, isOpen, onClose }: MandalartViewerProps) => {
  const [isExporting, setIsExporting] = useState(false);

  // Create 9x9 grid structure
  const createMandalartGrid = () => {
    const grid = Array(9).fill(null).map(() => Array(9).fill(null));
    
    // Center cell (4,4) - main goal
    grid[4][4] = { text: data.goal.centralGoal, type: 'goal', isCompleted: false };

    // Theme positions in center 3x3 (excluding center)
    const themePositions = [
      [3, 3], [3, 4], [3, 5],
      [4, 3],           [4, 5],
      [5, 3], [5, 4], [5, 5]
    ];

    data.themes.forEach((theme, index) => {
      if (index < 8) {
        const [row, col] = themePositions[index];
        grid[row][col] = { text: theme.themeText, type: 'theme', isCompleted: false };
      }
    });

    // Action items in outer positions
    data.themes.forEach((theme, themeIndex) => {
      if (themeIndex < 8) {
        const themeActions = data.actionItems.filter(
          action => action.themeId === theme.id
        ).sort((a, b) => a.order - b.order);

        // Define action positions for each theme
        const actionPositions = getActionPositions(themeIndex);
        
        themeActions.forEach((action, actionIndex) => {
          if (actionIndex < 8 && actionPositions[actionIndex]) {
            const [row, col] = actionPositions[actionIndex];
            grid[row][col] = { 
              text: action.actionText, 
              type: 'action', 
              isCompleted: action.isCompleted 
            };
          }
        });
      }
    });

    return grid;
  };

  const getActionPositions = (themeIndex: number) => {
    // Map each theme to its 8 action positions around the 9x9 grid
    const positions = [
      // Theme 0 (top-left) - positions around [3,3]
      [[0,0], [0,1], [0,2], [1,0], [1,2], [2,0], [2,1], [2,2]],
      // Theme 1 (top-center) - positions around [3,4]  
      [[0,3], [0,4], [0,5], [1,3], [1,5], [2,3], [2,4], [2,5]],
      // Theme 2 (top-right) - positions around [3,5]
      [[0,6], [0,7], [0,8], [1,6], [1,8], [2,6], [2,7], [2,8]],
      // Theme 3 (middle-left) - positions around [4,3]
      [[3,0], [3,1], [3,2], [4,0], [4,2], [5,0], [5,1], [5,2]],
      // Theme 4 (middle-right) - positions around [4,5]
      [[3,6], [3,7], [3,8], [4,6], [4,8], [5,6], [5,7], [5,8]],
      // Theme 5 (bottom-left) - positions around [5,3]
      [[6,0], [6,1], [6,2], [7,0], [7,2], [8,0], [8,1], [8,2]],
      // Theme 6 (bottom-center) - positions around [5,4]
      [[6,3], [6,4], [6,5], [7,3], [7,5], [8,3], [8,4], [8,5]],
      // Theme 7 (bottom-right) - positions around [5,5]
      [[6,6], [6,7], [6,8], [7,6], [7,8], [8,6], [8,7], [8,8]]
    ];
    return positions[themeIndex] || [];
  };

  const handleExport = async () => {
    setIsExporting(true);
    try {
      const element = document.getElementById('mandalart-grid');
      if (!element) return;

      // Use html2canvas for image export (would need to install)
      // For now, just create a simple download
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      canvas.width = 800;
      canvas.height = 800;
      
      if (ctx) {
        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, 800, 800);
        ctx.fillStyle = '#000000';
        ctx.font = '16px Arial';
        ctx.textAlign = 'center';
        ctx.fillText('만다라트 차트', 400, 50);
        ctx.fillText(data.goal.centralGoal, 400, 400);
      }

      const link = document.createElement('a');
      link.download = 'my-mandalart.png';
      link.href = canvas.toDataURL();
      link.click();
    } catch (error) {
      console.error('Export failed:', error);
    } finally {
      setIsExporting(false);
    }
  };

  const grid = createMandalartGrid();
  const completedActions = data.actionItems.filter(item => item.isCompleted).length;
  const totalActions = data.actionItems.filter(item => item.actionText.trim()).length;

  const MandalartGrid = () => (
    <div 
      id="mandalart-grid"
      className="bg-card p-6 rounded-lg shadow-soft border"
    >
      <div className="mb-4 text-center">
        <h2 className="text-2xl font-bold mb-2">나의 만다라트</h2>
        <p className="text-sm text-muted-foreground">
          {completedActions}/{totalActions} 액션아이템 완료
        </p>
      </div>
      
      <div className="grid grid-cols-9 gap-1 aspect-square max-w-2xl mx-auto">
        {grid.map((row, rowIndex) => 
          row.map((cell, colIndex) => (
            <div
              key={`${rowIndex}-${colIndex}`}
              className={cn(
                "aspect-square border text-xs flex items-center justify-center p-1 text-center leading-tight",
                cell?.type === 'goal' && "bg-gradient-primary text-primary-foreground font-bold text-sm",
                cell?.type === 'theme' && "bg-gradient-accent text-accent-foreground font-medium",
                cell?.type === 'action' && !cell.isCompleted && "bg-muted/50 text-muted-foreground",
                cell?.type === 'action' && cell.isCompleted && "bg-gradient-success text-success-foreground",
                !cell && "bg-background"
              )}
            >
              {cell?.text && (
                <span className="break-all overflow-hidden">
                  {cell.text.length > 20 ? `${cell.text.slice(0, 20)}...` : cell.text}
                </span>
              )}
            </div>
          ))
        )}
      </div>
    </div>
  );

  if (isOpen !== undefined) {
    // Modal mode
    return (
      <Dialog open={isOpen} onOpenChange={onClose}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-auto">
          <DialogHeader>
            <div className="flex justify-between items-center">
              <DialogTitle>만다라트 차트</DialogTitle>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={handleExport} disabled={isExporting}>
                  <Download className="w-4 h-4" />
                </Button>
                <Button variant="outline" size="sm" onClick={() => navigator.share?.({ title: '나의 만다라트' })}>
                  <Share className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </DialogHeader>
          <MandalartGrid />
        </DialogContent>
      </Dialog>
    );
  }

  // Full page mode
  return (
    <div className="min-h-screen bg-gradient-subtle p-6">
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-3xl font-bold">만다라트 차트</h1>
          <div className="flex gap-2">
            <Button variant="outline" onClick={handleExport} disabled={isExporting}>
              <Download className="w-4 h-4 mr-2" />
              이미지 저장
            </Button>
            <Button variant="accent" onClick={() => navigator.share?.({ title: '나의 만다라트' })}>
              <Share className="w-4 h-4 mr-2" />
              공유하기
            </Button>
            {onClose && (
              <Button variant="ghost" onClick={onClose}>
                <X className="w-4 h-4" />
              </Button>
            )}
          </div>
        </div>
        <MandalartGrid />
      </div>
    </div>
  );
};

export default MandalartViewer;