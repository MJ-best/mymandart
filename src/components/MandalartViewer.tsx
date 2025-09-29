import { useState } from "react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { MandalartData } from "@/types/mandalart";
import MandalartGrid from "./MandalartGrid";
import MandalartControls from "./MandalartControls";
import { exportMandalartAsImage, exportMandalartAsJSON } from "@/utils/mandalartExport";

interface MandalartViewerProps {
  data: MandalartData;
  isOpen?: boolean;
  onClose?: () => void;
}

const MandalartViewer = ({ data, isOpen, onClose }: MandalartViewerProps) => {
  const [isExporting, setIsExporting] = useState(false);
  const [currentView, setCurrentView] = useState<'full' | number>('full');

  const handleExport = async () => {
    setIsExporting(true);
    try {
      await exportMandalartAsImage(data);
    } finally {
      setIsExporting(false);
    }
  };

  const handleExportJSON = () => {
    exportMandalartAsJSON(data);
  };

  const handleThemeClick = (themeIndex: number) => {
    setCurrentView(themeIndex);
  };

  const handleBackToFull = () => {
    setCurrentView('full');
  };

  if (isOpen !== undefined) {
    // Modal mode
    return (
      <Dialog open={isOpen} onOpenChange={onClose}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-auto">
          <DialogHeader>
            <div className="flex justify-between items-center">
              <DialogTitle>만다라트 차트</DialogTitle>
              <MandalartControls
                isModal
                isExporting={isExporting}
                onExport={handleExport}
                onExportJSON={handleExportJSON}
              />
            </div>
          </DialogHeader>
          <MandalartGrid 
            data={data} 
            currentView={currentView}
            onCellClick={handleThemeClick}
            onBackToFull={handleBackToFull}
          />
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
          <MandalartControls
            isExporting={isExporting}
            onExport={handleExport}
            onExportJSON={handleExportJSON}
            onClose={onClose}
          />
        </div>
        <MandalartGrid 
          data={data} 
          currentView={currentView}
          onCellClick={handleThemeClick}
          onBackToFull={handleBackToFull}
        />
      </div>
    </div>
  );
};

export default MandalartViewer;