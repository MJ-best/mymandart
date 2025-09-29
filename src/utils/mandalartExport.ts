import { MandalartData } from "@/types/mandalart";
import html2canvas from 'html2canvas';

export const exportMandalartAsImage = async (data: MandalartData): Promise<void> => {
  try {
    const element = document.getElementById('mandalart-grid');
    if (!element) {
      console.error('Mandalart grid element not found');
      return;
    }

    // Use html2canvas for better quality export
    const canvas = await html2canvas(element, {
      backgroundColor: '#ffffff',
      scale: 2, // Higher resolution
      useCORS: true,
      allowTaint: true,
      width: element.offsetWidth,
      height: element.offsetHeight,
    });

    // Create download link
    const link = document.createElement('a');
    link.download = `mandalart-${new Date().toISOString().split('T')[0]}.png`;
    link.href = canvas.toDataURL('image/png', 1.0);
    
    // Trigger download
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  } catch (error) {
    console.error('Export failed:', error);
    // Fallback to simple canvas export
    await fallbackExport(data);
  }
};

const fallbackExport = async (data: MandalartData): Promise<void> => {
  try {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    canvas.width = 1200;
    canvas.height = 1200;
    
    if (ctx) {
      // Background
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(0, 0, 1200, 1200);
      
      // Title
      ctx.fillStyle = '#1f2937';
      ctx.font = 'bold 32px Arial';
      ctx.textAlign = 'center';
      ctx.fillText('나의 만다라트', 600, 80);
      
      // Goal
      ctx.fillStyle = '#3b82f6';
      ctx.font = 'bold 24px Arial';
      ctx.fillText(data.goal.centralGoal, 600, 150);
      
      // Themes
      ctx.fillStyle = '#6b7280';
      ctx.font = '16px Arial';
      data.themes.forEach((theme, index) => {
        const x = 200 + (index % 3) * 300;
        const y = 250 + Math.floor(index / 3) * 200;
        ctx.fillText(theme.themeText, x, y);
      });
      
      // Action items
      ctx.fillStyle = '#9ca3af';
      ctx.font = '12px Arial';
      data.actionItems.forEach((action, index) => {
        const x = 50 + (index % 8) * 140;
        const y = 400 + Math.floor(index / 8) * 100;
        ctx.fillText(action.actionText, x, y);
      });
    }

    const link = document.createElement('a');
    link.download = `mandalart-${new Date().toISOString().split('T')[0]}.png`;
    link.href = canvas.toDataURL();
    link.click();
  } catch (error) {
    console.error('Fallback export failed:', error);
  }
};

export const exportMandalartAsJSON = (data: MandalartData): void => {
  try {
    const jsonData = {
      goal: data.goal.centralGoal,
      themes: data.themes.map(theme => ({
        themeText: theme.themeText,
        actionItems: data.actionItems
          .filter(action => action.themeId === theme.id)
          .map(action => ({
            actionText: action.actionText,
            isCompleted: action.isCompleted
          }))
      })),
      exportedAt: new Date().toISOString()
    };

    const blob = new Blob([JSON.stringify(jsonData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    
    const link = document.createElement('a');
    link.href = url;
    link.download = `mandalart-${new Date().toISOString().split('T')[0]}.json`;
    link.click();
    
    URL.revokeObjectURL(url);
  } catch (error) {
    console.error('JSON export failed:', error);
  }
};