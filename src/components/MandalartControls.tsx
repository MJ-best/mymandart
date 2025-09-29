import { Button } from "@/components/ui/button";
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { Download, Share, X, FileText, Image } from "lucide-react";

interface MandalartControlsProps {
  isExporting?: boolean;
  onExport?: () => void;
  onExportJSON?: () => void;
  onShare?: () => void;
  onClose?: () => void;
  isModal?: boolean;
}

const MandalartControls = ({ 
  isExporting = false, 
  onExport, 
  onExportJSON,
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
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" size="sm" disabled={isExporting}>
              <Download className="w-4 h-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent>
            {onExport && (
              <DropdownMenuItem onClick={onExport}>
                <Image className="w-4 h-4 mr-2" />
                이미지로 저장
              </DropdownMenuItem>
            )}
            {onExportJSON && (
              <DropdownMenuItem onClick={onExportJSON}>
                <FileText className="w-4 h-4 mr-2" />
                JSON으로 저장
              </DropdownMenuItem>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
        <Button variant="outline" size="sm" onClick={handleShare}>
          <Share className="w-4 h-4" />
        </Button>
      </div>
    );
  }

  return (
    <div className="flex gap-2">
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="outline" disabled={isExporting}>
            <Download className="w-4 h-4 mr-2" />
            내보내기
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent>
          {onExport && (
            <DropdownMenuItem onClick={onExport}>
              <Image className="w-4 h-4 mr-2" />
              이미지로 저장
            </DropdownMenuItem>
          )}
          {onExportJSON && (
            <DropdownMenuItem onClick={onExportJSON}>
              <FileText className="w-4 h-4 mr-2" />
              JSON으로 저장
            </DropdownMenuItem>
          )}
        </DropdownMenuContent>
      </DropdownMenu>
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