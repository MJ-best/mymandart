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
  order: number; // 1-8
  createdAt: Date;
  updatedAt: Date;
}

export interface ActionItem {
  id: string;
  themeId: string;
  actionText: string;
  isCompleted: boolean;
  order: number; // 1-8
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
}