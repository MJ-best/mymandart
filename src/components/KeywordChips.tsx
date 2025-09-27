import { KeywordSuggestion } from "@/types/mandalart";
import { Button } from "@/components/ui/button";

interface KeywordChipsProps {
  suggestions: KeywordSuggestion[];
  onSelect: (keyword: string) => void;
  className?: string;
}

const KeywordChips = ({ suggestions, onSelect, className = "" }: KeywordChipsProps) => {
  return (
    <div className={`flex flex-wrap gap-2 ${className}`}>
      {suggestions.map((suggestion, index) => (
        <Button
          key={`${suggestion.text}-${index}`}
          variant="outline"
          size="sm"
          onClick={() => onSelect(suggestion.text)}
          className="rounded-full text-xs hover:bg-gradient-warm hover:text-primary-foreground border-primary/20 hover:border-primary/40 transition-bounce"
        >
          {suggestion.text}
        </Button>
      ))}
    </div>
  );
};

export default KeywordChips;