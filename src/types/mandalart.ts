export interface Goal {
  id: string;
  centralGoal: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Theme {
  id: string;
  goalId: string;
  themeText: string;
  order: number; // 0-7 (for array indexing)
  createdAt: Date;
  updatedAt: Date;
}

export interface ActionItem {
  id: string;
  themeId: string;
  actionText: string;
  isCompleted: boolean;
  order: number; // 0-7 (for array indexing)
  createdAt: Date;
  updatedAt: Date;
}

export interface MandalartData {
  goal: Goal;
  themes: Theme[];
  actionItems: ActionItem[];
}

export interface KeywordSuggestion {
  text: string;
  category: 'adjective' | 'verb' | 'noun';
  description?: string;
}

export interface MandalartProgress {
  totalThemes: number;
  completedThemes: number;
  totalActions: number;
  completedActions: number;
  completionPercentage: number;
}