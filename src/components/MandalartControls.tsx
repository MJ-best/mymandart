import { Button } from "@/components/ui/button";
import { Download, Share, X } from "lucide-react";

interface MandalartControlsProps {
  isExporting?: boolean;
  onExport?: () => void;
  onShare?: () => void;
  onClose?: () => void;
  isModal?: boolean;
}

const MandalartControls = ({ 
  isExporting = false, 
  onExport, 
  onShare, 
  onClose,
  isModal = false 
}: MandalartControlsProps) => {
  const handleShare = () => {
    if (onShare) {
      onShare();
    } else {
      navigator.share?.({ title: '나의 만다라트' });
    }
  };

  if (isModal) {
    return (
      <div className="flex gap-2">
        {onExport && (
          <Button variant="outline" size="sm" onClick={onExport} disabled={isExporting}>
            <Download className="w-4 h-4" />
          </Button>
        )}
        <Button variant="outline" size="sm" onClick={handleShare}>
          <Share className="w-4 h-4" />
        </Button>
      </div>
    );
  }

  return (
    <div className="flex gap-2">
      {onExport && (
        <Button variant="outline" onClick={onExport} disabled={isExporting}>
          <Download className="w-4 h-4 mr-2" />
          이미지 저장
        </Button>
      )}
      <Button variant="accent" onClick={handleShare}>
        <Share className="w-4 h-4 mr-2" />
        공유하기
      </Button>
      {onClose && (
        <Button variant="ghost" onClick={onClose}>
          <X className="w-4 h-4" />
        </Button>
      )}
    </div>
  );
};

export default MandalartControls;