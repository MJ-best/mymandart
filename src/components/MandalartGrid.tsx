import { cn } from "@/lib/utils";
import { MandalartData } from "@/types/mandalart";
import { createMandalartGrid, createThemeGrid, findClickedThemeIndex, GridCell } from "@/utils/mandalartGrid";

interface MandalartGridProps {
  data: MandalartData;
  currentView: 'full' | number;
  onCellClick?: (themeIndex: number) => void;
  onBackToFull?: () => void;
}

const MandalartGrid = ({ data, currentView, onCellClick, onBackToFull }: MandalartGridProps) => {
  const isFullView = currentView === 'full';
  const gridData = isFullView ? createMandalartGrid(data) : createThemeGrid(data, currentView as number);
  const gridSize = isFullView ? 9 : 3;
  
  const completedActions = data.actionItems.filter(item => item.isCompleted).length;
  const totalActions = data.actionItems.filter(item => item.actionText.trim()).length;

  const handleCellClick = (cell: GridCell | null, rowIndex: number, colIndex: number) => {
    if (!onCellClick) return;
    
    if (isFullView && cell?.type === 'theme') {
      const themeIndex = findClickedThemeIndex(rowIndex, colIndex);
      if (themeIndex !== -1) {
        onCellClick(themeIndex);
      }
    }
  };

  const getCellClassName = (cell: GridCell | null) => {
    return cn(
      "aspect-square border text-xs flex items-center justify-center p-1 text-center leading-tight transition-smooth",
      cell?.type === 'goal' && "bg-gradient-primary text-primary-foreground font-bold text-sm cursor-pointer hover:opacity-80",
      cell?.type === 'theme' && "bg-gradient-accent text-accent-foreground font-medium cursor-pointer hover:opacity-80 hover-scale",
      cell?.type === 'outer-theme' && "bg-gradient-secondary text-secondary-foreground font-medium border-2 border-accent/30",
      cell?.type === 'action' && !cell.isCompleted && "bg-muted/50 text-muted-foreground",
      cell?.type === 'action' && cell.isCompleted && "bg-gradient-success text-success-foreground",
      !cell && "bg-background",
      !isFullView && cell?.type === 'action' && "text-sm"
    );
  };

  return (
    <div 
      id="mandalart-grid"
      className="bg-card p-6 rounded-lg shadow-soft border"
    >
      <div className="mb-4 text-center">
        <div className="flex items-center justify-center gap-4 mb-2">
          {!isFullView && onBackToFull && (
            <button
              onClick={onBackToFull}
              className="text-sm text-muted-foreground hover:text-foreground transition-smooth flex items-center gap-1"
            >
              ← 전체보기
            </button>
          )}
          <h2 className="text-2xl font-bold">
            {isFullView ? '나의 만다라트' : data.themes[currentView as number]?.themeText}
          </h2>
        </div>
        <p className="text-sm text-muted-foreground">
          {completedActions}/{totalActions} 액션아이템 완료
        </p>
      </div>
      
      <div className={cn(
        "grid gap-1 aspect-square max-w-2xl mx-auto",
        isFullView ? "grid-cols-9" : "grid-cols-3"
      )}>
        {gridData.map((row, rowIndex) => 
          row.map((cell, colIndex) => (
            <div
              key={`${rowIndex}-${colIndex}`}
              onClick={() => handleCellClick(cell, rowIndex, colIndex)}
              className={getCellClassName(cell)}
            >
              {cell?.text && (
                <span className="break-all overflow-hidden animate-fade-in">
                  {!isFullView || cell.text.length <= 20 ? cell.text : `${cell.text.slice(0, 20)}...`}
                </span>
              )}
            </div>
          ))
        )}
      </div>
      
      {!isFullView && (
        <div className="mt-4 text-center">
          <p className="text-xs text-muted-foreground">
            💡 중앙의 테마를 클릭하거나 위의 "전체보기"를 클릭해서 전체 만다라트로 돌아갈 수 있습니다
          </p>
        </div>
      )}
    </div>
  );
};

export default MandalartGrid;