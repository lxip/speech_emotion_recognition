function savefig_pdf(fighandle, filepath)

set(fighandle,'Units','Inches');
pos = get(fighandle,'Position');
set(fighandle,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
% print(filehandle,filepath,'-dpdf','-r0')
saveas(gcf, filepath, 'pdf') %Save figure

end