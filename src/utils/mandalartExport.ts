import { MandalartData } from "@/types/mandalart";

export const exportMandalartAsImage = async (data: MandalartData): Promise<void> => {
  try {
    const element = document.getElementById('mandalart-grid');
    if (!element) return;

    // Simple canvas export (can be enhanced with html2canvas later)
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    canvas.width = 800;
    canvas.height = 800;
    
    if (ctx) {
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(0, 0, 800, 800);
      ctx.fillStyle = '#000000';
      ctx.font = '16px Arial';
      ctx.textAlign = 'center';
      ctx.fillText('만다라트 차트', 400, 50);
      ctx.fillText(data.goal.centralGoal, 400, 400);
    }

    const link = document.createElement('a');
    link.download = 'my-mandalart.png';
    link.href = canvas.toDataURL();
    link.click();
  } catch (error) {
    console.error('Export failed:', error);
  }
};