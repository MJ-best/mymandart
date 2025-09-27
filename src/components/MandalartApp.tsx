import { useState, useEffect, useMemo } from "react";
import { useLocalStorage } from "@/hooks/useLocalStorage";
import { MandalartData, Goal, Theme, ActionItem } from "@/types/mandalart";
import GoalDefinitionStep from "./steps/GoalDefinitionStep";
import ThemeStep from "./steps/ThemeStep";
import ActionItemsStep from "./steps/ActionItemsStep";
import MandalartViewer from "./MandalartViewer";

const MandalartApp = () => {
  const [currentStep, setCurrentStep] = useState(0);
  const [showViewer, setShowViewer] = useState(false);
  
  // LocalStorage state
  const [goalText, setGoalText] = useLocalStorage("mandalart-goal", "");
  const [themes, setThemes] = useLocalStorage<string[]>("mandalart-themes", Array(8).fill(""));
  const [actionItems, setActionItems] = useLocalStorage<ActionItem[]>("mandalart-actions", []);
  const [currentStepStorage, setCurrentStepStorage] = useLocalStorage("mandalart-current-step", 0);

  // Load current step from storage on mount
  useEffect(() => {
    setCurrentStep(currentStepStorage);
  }, [currentStepStorage]);

  // Create MandalartData structure
  const mandalartData: MandalartData = useMemo(() => {
    const goal: Goal = {
      id: "main-goal",
      centralGoal: goalText,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const themeData: Theme[] = themes.map((themeText, index) => ({
      id: `theme-${index}`,
      goalId: "main-goal",
      themeText,
      order: index,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));

    return {
      goal,
      themes: themeData,
      actionItems,
    };
  }, [goalText, themes, actionItems]);

  const handleStepChange = (step: number) => {
    setCurrentStep(step);
    setCurrentStepStorage(step);
  };

  const handleGoalChange = (value: string) => {
    setGoalText(value);
  };

  const handleThemesChange = (newThemes: string[]) => {
    setThemes(newThemes);
  };

  const handleActionItemsChange = (newActionItems: ActionItem[]) => {
    setActionItems(newActionItems);
  };

  const handleNext = () => {
    if (currentStep < 2) {
      handleStepChange(currentStep + 1);
    } else {
      // Final step - show completed view
      setShowViewer(true);
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      handleStepChange(currentStep - 1);
    }
  };

  const handleViewMandalart = () => {
    setShowViewer(true);
  };

  const handleCloseViewer = () => {
    setShowViewer(false);
  };

  // If viewing mandalart, show full-page viewer
  if (showViewer) {
    return (
      <MandalartViewer 
        data={mandalartData} 
        onClose={handleCloseViewer}
      />
    );
  }

  return (
    <div className="min-h-screen">
      {currentStep === 0 && (
        <GoalDefinitionStep
          value={goalText}
          onChange={handleGoalChange}
          onNext={handleNext}
          onPrevious={handlePrevious}
        />
      )}
      
      {currentStep === 1 && (
        <ThemeStep
          goalText={goalText}
          themes={themes}
          onChange={handleThemesChange}
          onNext={handleNext}
          onPrevious={handlePrevious}
        />
      )}
      
      {currentStep === 2 && (
        <ActionItemsStep
          goalText={goalText}
          themes={themes.filter(t => t.trim())}
          actionItems={actionItems}
          onChange={handleActionItemsChange}
          onNext={handleNext}
          onPrevious={handlePrevious}
          onViewMandalart={handleViewMandalart}
        />
      )}
    </div>
  );
};

export default MandalartApp;