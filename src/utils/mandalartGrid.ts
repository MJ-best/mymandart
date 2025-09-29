import { MandalartData } from "@/types/mandalart";

export interface GridCell {
  text: string;
  type: 'goal' | 'theme' | 'outer-theme' | 'action';
  isCompleted: boolean;
}

// Create 9x9 grid for full mandalart view
export const createMandalartGrid = (data: MandalartData): (GridCell | null)[][] => {
  const grid: (GridCell | null)[][] = Array(9).fill(null).map(() => Array(9).fill(null));
  
  // Center cell (4,4) - main goal
  grid[4][4] = { text: data.goal.centralGoal, type: 'goal', isCompleted: false };

  // Theme positions in center 3x3 (excluding center)
  const themePositions: [number, number][] = [
    [3, 3], [3, 4], [3, 5],
    [4, 3],           [4, 5],
    [5, 3], [5, 4], [5, 5]
  ];

  // Place themes in center grid
  data.themes.forEach((theme, index) => {
    if (index < 8) {
      const [row, col] = themePositions[index];
      grid[row][col] = { text: theme.themeText, type: 'theme', isCompleted: false };
    }
  });

  // Place action items and outer themes
  data.themes.forEach((theme, themeIndex) => {
    if (themeIndex < 8) {
      const themeActions = data.actionItems
        .filter(action => action.themeId === theme.id)
        .sort((a, b) => a.order - b.order);

      const actionPositions = getActionPositions(themeIndex);
      const themeCenterPositions: [number, number][] = [
        [1,1], [1,4], [1,7], [4,1], [4,7], [7,1], [7,4], [7,7]
      ];
      
      // Add theme in the center of each outer 3x3 area
      if (themeCenterPositions[themeIndex]) {
        const [row, col] = themeCenterPositions[themeIndex];
        grid[row][col] = { 
          text: theme.themeText, 
          type: 'outer-theme', 
          isCompleted: false 
        };
      }
      
      // Add action items around each theme
      themeActions.forEach((action, actionIndex) => {
        if (actionIndex < 8 && actionPositions[actionIndex]) {
          const [row, col] = actionPositions[actionIndex];
          grid[row][col] = { 
            text: action.actionText, 
            type: 'action', 
            isCompleted: action.isCompleted 
          };
        }
      });
    }
  });

  return grid;
};

// Create 3x3 grid for single theme view
export const createThemeGrid = (data: MandalartData, themeIndex: number): (GridCell | null)[][] => {
  const grid: (GridCell | null)[][] = Array(3).fill(null).map(() => Array(3).fill(null));
  const theme = data.themes[themeIndex];
  
  if (!theme) return grid;
  
  // Center cell - theme
  grid[1][1] = { text: theme.themeText, type: 'theme', isCompleted: false };
  
  // Action items around the theme
  const themeActions = data.actionItems
    .filter(action => action.themeId === theme.id)
    .sort((a, b) => a.order - b.order);
  
  const actionPositions: [number, number][] = [
    [0, 0], [0, 1], [0, 2],
    [1, 0],           [1, 2],
    [2, 0], [2, 1], [2, 2]
  ];
  
  themeActions.forEach((action, index) => {
    if (index < 8 && actionPositions[index]) {
      const [row, col] = actionPositions[index];
      grid[row][col] = {
        text: action.actionText,
        type: 'action',
        isCompleted: action.isCompleted
      };
    }
  });
  
  return grid;
};

// Get action positions for each theme in the 9x9 grid
const getActionPositions = (themeIndex: number): [number, number][] => {
  const positions: [number, number][][] = [
    // Theme 0 (top-left)
    [[0,0], [0,1], [0,2], [1,0], [1,2], [2,0], [2,1], [2,2]],
    // Theme 1 (top-center)
    [[0,3], [0,4], [0,5], [1,3], [1,5], [2,3], [2,4], [2,5]],
    // Theme 2 (top-right)
    [[0,6], [0,7], [0,8], [1,6], [1,8], [2,6], [2,7], [2,8]],
    // Theme 3 (middle-left)
    [[3,0], [3,1], [3,2], [4,0], [4,2], [5,0], [5,1], [5,2]],
    // Theme 4 (middle-right)
    [[3,6], [3,7], [3,8], [4,6], [4,8], [5,6], [5,7], [5,8]],
    // Theme 5 (bottom-left)
    [[6,0], [6,1], [6,2], [7,0], [7,2], [8,0], [8,1], [8,2]],
    // Theme 6 (bottom-center)
    [[6,3], [6,4], [6,5], [7,3], [7,5], [8,3], [8,4], [8,5]],
    // Theme 7 (bottom-right)
    [[6,6], [6,7], [6,8], [7,6], [7,8], [8,6], [8,7], [8,8]]
  ];
  return positions[themeIndex] || [];
};

// Find which theme was clicked in the center 3x3
export const findClickedThemeIndex = (rowIndex: number, colIndex: number): number => {
  const themePositions: [number, number][] = [
    [3, 3], [3, 4], [3, 5],
    [4, 3],         [4, 5],
    [5, 3], [5, 4], [5, 5]
  ];
  return themePositions.findIndex(([r, c]) => r === rowIndex && c === colIndex);
};