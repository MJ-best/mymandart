import { cn } from "@/lib/utils";

interface ProgressIndicatorProps {
  currentStep: number;
  totalSteps: number;
  className?: string;
}

const ProgressIndicator = ({ currentStep, totalSteps, className }: ProgressIndicatorProps) => {
  return (
    <div className={cn("flex items-center justify-center gap-2", className)}>
      {Array.from({ length: totalSteps }, (_, index) => (
        <div
          key={index}
          className={cn(
            "h-2 rounded-full transition-smooth",
            index < currentStep 
              ? "w-8 bg-gradient-primary shadow-warm" 
              : index === currentStep
              ? "w-12 bg-gradient-primary shadow-warm"
              : "w-2 bg-muted"
          )}
        />
      ))}
    </div>
  );
};

export default ProgressIndicator;