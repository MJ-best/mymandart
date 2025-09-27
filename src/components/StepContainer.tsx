import { ReactNode } from "react";
import { Button } from "@/components/ui/button";
import { ChevronLeft, ChevronRight } from "lucide-react";
import ProgressIndicator from "./ProgressIndicator";

interface StepContainerProps {
  children: ReactNode;
  currentStep: number;
  totalSteps: number;
  onNext?: () => void;
  onPrevious?: () => void;
  nextDisabled?: boolean;
  nextLabel?: string;
  showPrevious?: boolean;
  title: string;
  subtitle?: string;
}

const StepContainer = ({
  children,
  currentStep,
  totalSteps,
  onNext,
  onPrevious,
  nextDisabled = false,
  nextLabel = "다음",
  showPrevious = true,
  title,
  subtitle,
}: StepContainerProps) => {
  return (
    <div className="min-h-screen bg-gradient-subtle flex flex-col">
      <div className="flex-1 flex flex-col items-center justify-center p-6">
        <div className="w-full max-w-2xl">
          {/* Progress */}
          <ProgressIndicator 
            currentStep={currentStep} 
            totalSteps={totalSteps} 
            className="mb-8"
          />
          
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-foreground mb-2">{title}</h1>
            {subtitle && (
              <p className="text-lg text-muted-foreground">{subtitle}</p>
            )}
          </div>
          
          {/* Content */}
          <div className="bg-card rounded-xl shadow-soft border p-8 mb-8">
            {children}
          </div>
          
          {/* Navigation */}
          <div className="flex justify-between items-center">
            {showPrevious && currentStep > 0 ? (
              <Button 
                variant="ghost" 
                onClick={onPrevious}
                className="gap-2"
              >
                <ChevronLeft className="w-4 h-4" />
                이전
              </Button>
            ) : (
              <div />
            )}
            
            {onNext && (
              <Button 
                variant="hero" 
                onClick={onNext}
                disabled={nextDisabled}
                className="gap-2 min-w-32"
              >
                {nextLabel}
                <ChevronRight className="w-4 h-4" />
              </Button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepContainer;