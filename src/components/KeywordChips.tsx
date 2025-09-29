import { KeywordSuggestion } from "@/types/mandalart";
import { Button } from "@/components/ui/button";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Badge } from "@/components/ui/badge";

interface KeywordChipsProps {
  suggestions: KeywordSuggestion[];
  onSelect: (keyword: string) => void;
  className?: string;
  showDescriptions?: boolean;
  maxItems?: number;
}

const KeywordChips = ({ 
  suggestions, 
  onSelect, 
  className = "", 
  showDescriptions = true,
  maxItems = 12 
}: KeywordChipsProps) => {
  const displaySuggestions = suggestions.slice(0, maxItems);
  
  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'adjective': return 'bg-blue-100 text-blue-800 border-blue-200';
      case 'noun': return 'bg-green-100 text-green-800 border-green-200';
      case 'verb': return 'bg-purple-100 text-purple-800 border-purple-200';
      default: return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  return (
    <TooltipProvider>
      <div className={`flex flex-wrap gap-2 ${className}`}>
        {displaySuggestions.map((suggestion, index) => (
          <Tooltip key={`${suggestion.text}-${index}`}>
            <TooltipTrigger asChild>
              <Button
                variant="outline"
                size="sm"
                onClick={() => onSelect(suggestion.text)}
                className="rounded-full text-xs hover:bg-gradient-warm hover:text-primary-foreground border-primary/20 hover:border-primary/40 transition-bounce group relative"
              >
                <div className="flex items-center gap-1">
                  <span>{suggestion.text}</span>
                  <Badge 
                    variant="secondary" 
                    className={`text-xs px-1 py-0 ${getCategoryColor(suggestion.category)}`}
                  >
                    {suggestion.category === 'adjective' ? '형' : 
                     suggestion.category === 'noun' ? '명' : '동'}
                  </Badge>
                </div>
              </Button>
            </TooltipTrigger>
            {showDescriptions && suggestion.description && (
              <TooltipContent>
                <p className="text-sm">{suggestion.description}</p>
              </TooltipContent>
            )}
          </Tooltip>
        ))}
      </div>
    </TooltipProvider>
  );
};

export default KeywordChips;