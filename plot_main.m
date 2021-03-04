close all; clear; clc;
addpath(genpath('./utils/'));
addpath(genpath('./codes/'));

db = {'IAPRTC-12','MIRFLICKR','NUSWIDE10'};

for dbi = 1   :length(db)
    db_name = db{dbi}; param.db_name = db_name;
    
    % load dataset
    load(['./results/final_', db_name,'_result_0520.mat']);
    hashmethods = {'SCM-seq','DCH','FDCH','SCRATCH','LCMFH','DLFH','SRLCH','FCMH'};
    
    plot_idx = [1];%i-th in loopnbits
    
    % plot attribution
    line_width=1;%2;
    gcaline_width = 0.5;
    marker_size=5;%8;
    xy_font_size=14;%14;
    legend_font_size=12;%12;
    title_font_size=14;
    gca_size = 14;
    location = 'northeast'; %'best','northeast'
    
    % save result
    result_URL = sprintf('./results/fig/%s/',db_name);
    if ~isdir(result_URL)
        mkdir(result_URL);
    end

%     %% show mAP. This mAP function is provided by Yunchao Gong
%     % Image-to-Text
%     figure('Color', [1 1 1]); hold on;
%     for j = 1: length(hashmethods)
%         Image_VS_Text_map = [];
%         for i = 1: length(loopnbits)
%             Image_VS_Text_map = [Image_VS_Text_map, Image_VS_Text_MAP{j, i}];
%         end
%         p = plot(1:length(loopnbits), Image_VS_Text_map);
%         color=gen_color(j);
%         marker=gen_marker(j);
%         set(p,'Color', color);
%         set(p,'Marker', marker);
%         set(p,'LineWidth', line_width);
%         set(p,'MarkerSize', marker_size);
%     end
%     set(gcf,'unit','centimeters','position',[10 5 16 14]);
%     set(gca,'Position',[.2 .2 .65 .65],'fontsize',gca_size);
%     
%     set(gca,'yTickLabel',num2str(get(gca,'yTick')','%.2f'))
% 
%     h1 = xlabel('Number of bits');
%     h2 = ylabel('mean Average Precision (mAP)');
%     title('Image-to-Text','FontSize', title_font_size);
%     set(h1, 'FontSize', xy_font_size);
%     set(h2, 'FontSize', xy_font_size);
%     set(gca, 'xtick', 1:length(loopnbits));
%     set(gca, 'XtickLabel', cellstr(num2str(loopnbits(:)))');
%     set(gca, 'linewidth', gcaline_width);
%     hleg = legend(hashmethods);
%     set(hleg, 'FontSize', legend_font_size);
%     set(hleg, 'Location', location);
%     set(hleg,'Orientation','horizon')
%     set(gcf,'paperpositionmode','auto');
%     box on;
%     grid on;
%     hold off;
%     saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_mAP_ItoT',db_name,db_name),'fig');
%     saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_mAP_ItoT',db_name,db_name),'jpg');
%     saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_mAP_ItoT',db_name,db_name),'epsc2');
%     %print(gcf,'-depsc2',sprintf('./results/%s/final_%s_fig_mAP_ItoT',db_name,db_name))
%     
%     
%     % Text-To-Image
%     figure('Color', [1 1 1]); hold on;
%     for j = 1: length(hashmethods)
%         Text_VS_Image_map = [];
%         for i = 1: length(loopnbits)
%             Text_VS_Image_map = [Text_VS_Image_map, Text_VS_Image_MAP{j, i}];
%         end
%         p = plot(1:length(loopnbits), Text_VS_Image_map);
%         color=gen_color(j);
%         marker=gen_marker(j);
%         set(p,'Color', color);
%         set(p,'Marker', marker);
%         set(p,'LineWidth', line_width);
%         set(p,'MarkerSize', marker_size);
%     end
%     set(gcf,'unit','centimeters','position',[10 5 16 14]);
%     set(gca,'Position',[.2 .2 .65 .65],'fontsize',gca_size);
%     
%     set(gca,'yTickLabel',num2str(get(gca,'yTick')','%.2f'))
% 
%     h1 = xlabel('Number of bits');
%     h2 = ylabel('mean Average Precision (mAP)');
%     title('Text-to-Image', 'FontSize', title_font_size);
%     set(h1, 'FontSize', xy_font_size);
%     set(h2, 'FontSize', xy_font_size);
%     set(gca, 'xtick', 1:length(loopnbits));
%     set(gca, 'XtickLabel', cellstr(num2str(loopnbits(:)))');
%     set(gca, 'linewidth', gcaline_width);
%     hleg = legend(hashmethods);
%     set(hleg, 'FontSize', legend_font_size);
%     set(hleg, 'Location', location);
%     set(gcf,'paperpositionmode','auto');
%     box on;
%     grid on;
%     hold off;
%     saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_mAP_TtoI',db_name,db_name),'fig');
%     saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_mAP_TtoI',db_name,db_name),'jpg');
%     saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_mAP_TtoI',db_name,db_name),'epsc2');
    
    
    %% show precision vs recall
    for i = plot_idx
        str_nbits =  num2str(loopnbits(i));
        
        % Image-To-Text
        figure('Color', [1 1 1]); hold on;
        pr_ind = [2:50:1000,1000];
        for j = 1: length(hashmethods)
            p = plot(Image_VS_Text_recall{j,i},Image_VS_Text_precision{j,i});
            color=gen_color(j);
            marker=gen_marker(j);
            set(p,'Color', color)
            set(p,'Marker', marker);
            set(p,'LineWidth', line_width);
            set(p,'MarkerSize', marker_size);
        end
        set(gcf,'unit','centimeters','position',[10 5 16 14]);
        set(gca,'Position',[.2 .2 .65 .65],'fontsize',gca_size);
        

        h1 = xlabel('Recall');
        h2 = ylabel('Precision');
        title(['Image-to-Text @ ',str_nbits,'-bit']);
        set(h1, 'FontSize', xy_font_size);
        set(h2, 'FontSize', xy_font_size);
        hleg = legend(hashmethods);
        set(hleg, 'FontSize', legend_font_size);
        set(hleg,'Location', location);
        
        switch(db_name)
            case 'IAPRTC-12'
                set(gca,'YLim',[0.2  0.7]);set(gca,'YTick',[0.2:0.1:0.7]);
            case 'MIRFLICKR'
                set(gca,'YLim',[0.5  0.9]);set(gca,'YTick',[0.5:0.1:0.9]);
                %set(gca,'yTickLabel',num2str(get(gca,'yTick')','%.2f'))
            case 'NUSWIDE10'
                set(gca,'YLim',[0.3  0.9]);set(gca,'YTick',[0.3:0.1:0.9]);
        end
        
        set(gca, 'linewidth', gcaline_width);
        set(gcf,'paperpositionmode','auto');
        box on;
        grid on;
        hold off;
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PR_ItoT@%s',db_name,db_name,str_nbits),'fig');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PR_ItoT@%s',db_name,db_name,str_nbits),'jpg');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PR_ItoT@%s',db_name,db_name,str_nbits),'epsc2');
        
        % Text-To-Image
        figure('Color', [1 1 1]); hold on;
        for j = 1: length(hashmethods)
            p = plot(Text_VS_Image_recall{j,i},Text_VS_Image_precision{j,i});
            color=gen_color(j);
            marker=gen_marker(j);
            set(p,'Color', color)
            set(p,'Marker', marker);
            set(p,'LineWidth', line_width);
            set(p,'MarkerSize', marker_size);
        end
        set(gcf,'unit','centimeters','position',[10 5 16 14]);
        set(gca,'Position',[.2 .2 .65 .65],'fontsize',gca_size);
        

        h1 = xlabel('Recall');
        h2 = ylabel('Precision');
        title(['Text-to-Image @ ',str_nbits,'-bit']);
        set(h1, 'FontSize', xy_font_size);
        set(h2, 'FontSize', xy_font_size);
        hleg = legend(hashmethods);
        set(hleg, 'FontSize', legend_font_size);
        set(hleg,'Location', location);
        
        switch(db_name)
            case 'IAPRTC-12'
                set(gca,'YLim',[0.2  0.7]);set(gca,'YTick',[0.2:0.1:0.7]);
            case 'MIRFLICKR'
                set(gca,'YLim',[0.5  0.9]);set(gca,'YTick',[0.5:0.1:0.9]);
                %set(gca,'yTickLabel',num2str(get(gca,'yTick')','%.2f'))
            case 'NUSWIDE10'
                set(gca,'YLim',[0.3  0.9]);set(gca,'YTick',[0.3:0.1:0.9]);
        end
        
        set(gca, 'linewidth', gcaline_width);
        set(gcf,'paperpositionmode','auto');
        box on;
        grid on;
        hold off;
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PR_TtoI@%s',db_name,db_name,str_nbits),'fig');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PR_TtoI@%s',db_name,db_name,str_nbits),'jpg');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PR_TtoI@%s',db_name,db_name,str_nbits),'epsc2');
    end
        
    %% Top number precision
    for i = plot_idx
        str_nbits =  num2str(loopnbits(i));
        
        % Image-To-Text
        figure('Color', [1 1 1]); hold on;
        pn_pos = [1:100:2000,2000];
        for j = 1: length(hashmethods)
            p = plot(pn_pos, Image_To_Text_Precision{j,i});
            color = gen_color(j);
            marker = gen_marker(j);
            set(p,'Color', color)
            set(p,'Marker', marker);
            set(p,'LineWidth', line_width);
            set(p,'MarkerSize', marker_size);
        end
        set(gcf,'unit','centimeters','position',[10 5 16 14]);
        set(gca,'Position',[.2 .2 .65 .65],'fontsize',gca_size);
        

        h1 = xlabel('N');
        h2 = ylabel('Precision');
        title(['Image-to-Text @ ',str_nbits,'-bit']);  
        set(h1, 'FontSize', xy_font_size);
        set(h2, 'FontSize', xy_font_size);
        hleg = legend(hashmethods);
        set(hleg, 'FontSize', legend_font_size);
        set(hleg,'Location', 'southeast');
        
        switch(db_name)
            case 'IAPRTC-12'
                set(gca,'YLim',[0.2  0.7]);set(gca,'YTick',[0.2:0.1:0.7]);
            case 'MIRFLICKR'
                set(gca,'YLim',[0.5  0.9]);set(gca,'YTick',[0.5:0.1:0.9]);
                %set(gca,'yTickLabel',num2str(get(gca,'yTick')','%.2f'))
            case 'NUSWIDE10'
                set(gca,'YLim',[0.3  0.9]);set(gca,'YTick',[0.3:0.1:0.9]);
        end
        
        set(gca, 'linewidth', gcaline_width);
        set(gcf,'paperpositionmode','auto');
        box on;
        grid on;
        hold off;
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PN_ItoT@%s',db_name,db_name,str_nbits),'fig');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PN_ItoT@%s',db_name,db_name,str_nbits),'jpg');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PN_ItoT@%s',db_name,db_name,str_nbits),'epsc2');
        
        % Text-To-Image
        figure('Color', [1 1 1]); hold on;
        for j = 1: length(hashmethods)
            p = plot(pn_pos, Text_To_Image_Precision{j,i});
            color = gen_color(j);
            marker = gen_marker(j);
            set(p,'Color', color)
            set(p,'Marker', marker);
            set(p,'LineWidth', line_width);
            set(p,'MarkerSize', marker_size);
        end
        set(gcf,'unit','centimeters','position',[10 5 16 14]);
        set(gca,'Position',[.2 .2 .65 .65],'fontsize',gca_size);
        

        h1 = xlabel('N');
        h2 = ylabel('Precision');
        title(['Text-to-Image @ ',str_nbits,'-bit']);  
        set(h1, 'FontSize', xy_font_size);
        set(h2, 'FontSize', xy_font_size);
        hleg = legend(hashmethods);
        set(hleg, 'FontSize', legend_font_size);
        set(hleg,'Location', 'southeast');
        
        switch(db_name)
            case 'IAPRTC-12'
                set(gca,'YLim',[0.2  0.7]);set(gca,'YTick',[0.2:0.1:0.7]);
            case 'MIRFLICKR'
                set(gca,'YLim',[0.5  0.9]);set(gca,'YTick',[0.5:0.1:0.9]);
                %set(gca,'yTickLabel',num2str(get(gca,'yTick')','%.2f'))
            case 'NUSWIDE10'
                set(gca,'YLim',[0.3  0.9]);set(gca,'YTick',[0.3:0.1:0.9]);
        end
        
        set(gca, 'linewidth', gcaline_width);
        set(gcf,'paperpositionmode','auto');
        box on;
        grid on;
        hold off;
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PN_TtoI@%s',db_name,db_name,str_nbits),'fig');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PN_TtoI@%s',db_name,db_name,str_nbits),'jpg');
        saveas(gcf, sprintf('./results/fig/%s/final_%s_fig_PN_TtoI@%s',db_name,db_name,str_nbits),'epsc2');
    end
        
end
