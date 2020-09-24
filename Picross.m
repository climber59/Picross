%{
numbers as individual objecst so they can be turned on and off individually

move preview while dragging
- include a number showing the count

left click removes squares only if the whole line is squares

size controls

number text shouldnt go off screen

undo button

support for row/col with no numbers
%}
function [ ] = Picross( )
	f = [];
	ax = [];
	pGrid = [];
	vText = [];
	hText = [];
	
	ansKey =[];
	n = [];
	winner = [];
	vertNums = [];
	horNums = [];
	
	figureSetup();
	newGame();
	
	
	function [] = newGame(~,~)
		cla;
		
		n = 10;
		randGen();
		
% 		vertNums = {[3 2 1] [1 2 2 2] [3 1 2 2] [3 2 3] [4 3] [2 2 2] [1 1 3 1] [2 2 2 ] [1 1 4] [1 1 2 2] [1 1 2 3] [1 1 2 2] [1 1 2 1] [1 1 2 2] [1 1 2 4]};
% 		horNums = {[2] [1 8] [2 3] [1 3] [5 8] [2 4] [4 ] [3 3] [2 7] [1 6] [5 2] [4 2 2] [3 2 1] [3 2 1] [2 1 2 1]};

		
		build();
		winner = false;
	end
	
	function [] = numDetect()
		fcn = @(x) x.UserData.filled || x.UserData.x;
		
		% get numbers
		cvertNums = {};
		chorNums = {};
		for i = 1:n
			% go down a column
			j = 1;
			ind = 1;
			while j <= n
				c = 0;
				while j<=n && pGrid(j,i).UserData.filled
					c = c + 1;
					j = j + 1;
				end
				if c~=0
					cvertNums{i}(ind) = c; % change to cell, edit array in each, a{1}(2) works
					ind = ind + 1;
				end
				j = j + 1;
			end
			
			% go right a row
			j = 1;
			ind = 1;
			while j <= n
				c = 0;
				while j<=n && pGrid(i,j).UserData.filled
					c = c + 1;
					j = j + 1;
				end
				if c~=0
					chorNums{i}(ind) = c;
					ind = ind + 1;
				end
				j = j + 1;
			end
			
			if length(cvertNums) < i
				cvertNums{i} = [];
			end
			if length(chorNums) < i
				chorNums{i} = [];
			end
		end
		
		%fill x's
		for i = 1:n
			%check col
			if length(cvertNums{i})==length(vertNums{i}) && all(cvertNums{i} == vertNums{i})
				for j = 1:n
					if ~pGrid(j,i).UserData.filled && ~pGrid(j,i).UserData.x
						pGrid(j,i).UserData.x = true;
						pGrid(j,i).UserData.xT.Visible = 'on';
					end
				end
				vText(i).Color = 0.75*ones(1,3);%[0.5 0.5 0.5];
			elseif all(arrayfun(fcn,pGrid(:,i)))
				vText(i).Color = [1 0 0];
			else
				vText(i).Color = [0 0 0];
			end
			%check row
			if length(chorNums{i})==length(horNums{i}) && all(chorNums{i} == horNums{i})
				for j = 1:n
					if ~pGrid(i,j).UserData.filled && ~pGrid(i,j).UserData.x
						pGrid(i,j).UserData.x = true;
						pGrid(i,j).UserData.xT.Visible = 'on';
					end
				end
				hText(i).Color = 0.75*ones(1,3);
			elseif all(arrayfun(fcn,pGrid(i,:)))
				hText(i).Color = [1 0 0];
			else
				hText(i).Color = [0 0 0];
			end
		end
		
		% win check
		w = true;
		i = 1;
		while i<=n && w
			w = (length(cvertNums{i})==length(vertNums{i}) && all(cvertNums{i} == vertNums{i})) && (length(chorNums{i})==length(horNums{i}) && all(chorNums{i} == horNums{i}));
			i = i + 1;
		end
		if w
			winner = true;
			patch(1.5+(n-1)*[0 9 37 87 100 42]/100,1.5+(n-1)*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none');
		end
		
	end
	
	function [] = click(~,~)
		if winner
			return
		end
		
		m = fliplr(floor(ax.CurrentPoint([1,3])));
		if any(m < 1) || any(m > n)
			return;
		end
		
		f.WindowButtonUpFcn = {@unclick, m};
% 		switch f.SelectionType
% 			case 'normal'
% 				pGrid(m(1),m(2)).FaceColor = ~pGrid(m(1),m(2)).FaceColor;
% 			case 'alt'
% 				pGrid(m(1),m(2)).UserData.x = ~pGrid(m(1),m(2)).UserData.x;
% 				if pGrid(m(1),m(2)).UserData.x
% 					pGrid(m(1),m(2)).UserData.xT.Visible = 'on';
% 				else
% 					pGrid(m(1),m(2)).UserData.xT.Visible = 'off';
% 				end
% 		end
	end
	
	function [] = unclick(~,~,m1)
		f.WindowButtonUpFcn = [];
		
		%get second point, filter bad values
		m2 = fliplr(floor(ax.CurrentPoint([1,3])));
		if any(m2 < 1) || any(m2 > n)
			if any(m2 < 0) || any(m2 > n+1)
				return;
			end
			m2 = min(max(m2,1),n);	
		end
		
		% single square
		if m2 == m1
			switch f.SelectionType
				case 'normal'
					pGrid(m1(1),m1(2)).FaceColor = ~pGrid(m1(1),m1(2)).FaceColor;
					pGrid(m1(1),m1(2)).UserData.filled = ~pGrid(m1(1),m1(2)).UserData.filled;
					pGrid(m1(1),m1(2)).UserData.x = false;
					pGrid(m1(1),m1(2)).UserData.xT.Visible = 'off';
				case 'alt'
					pGrid(m1(1),m1(2)).UserData.x = ~pGrid(m1(1),m1(2)).UserData.x;
					if pGrid(m1(1),m1(2)).UserData.x
						pGrid(m1(1),m1(2)).UserData.xT.Visible = 'on';
					else
						pGrid(m1(1),m1(2)).UserData.xT.Visible = 'off';
					end
					pGrid(m1(1),m1(2)).FaceColor = [1 1 1];
					pGrid(m1(1),m1(2)).UserData.filled = false;
			end
		else
		
			% pick which direction to fill
			[~,i] = max(abs(m1-m2));
			if i==1 % draw on a column
				r = min(m1(1),m2(1)):max(m1(1),m2(1));
				c = m1(2)*ones(size(r));
			else % draw on a row
				c = min(m1(2),m2(2)):max(m1(2),m2(2));
				r = m1(1)*ones(size(c));
			end

			% fill
			switch f.SelectionType
				case 'normal'
					s = pGrid(m1(1),m1(2)).UserData.filled;
					for i = 1:length(c)
						if pGrid(r(i),c(i)).UserData.filled == s && ~pGrid(r(i),c(i)).UserData.x
							pGrid(r(i),c(i)).FaceColor = ~pGrid(r(i),c(i)).FaceColor;
							pGrid(r(i),c(i)).UserData.filled = ~s;
						end
					end
				case 'alt'
					s = pGrid(m1(1),m1(2)).UserData.x;
					for i = 1:length(c)
						if pGrid(r(i),c(i)).UserData.x == s && ~pGrid(r(i),c(i)).UserData.filled
							pGrid(r(i),c(i)).UserData.x = ~pGrid(r(i),c(i)).UserData.x;
							if pGrid(r(i),c(i)).UserData.x
								pGrid(r(i),c(i)).UserData.xT.Visible = 'on';
							else
								pGrid(r(i),c(i)).UserData.xT.Visible = 'off';
							end
						end
					end
			end
		end
		
		numDetect();
	end
	
	function [] = build()
		pGrid = gobjects(n);
		for r = 1:n
			for c = 1:n
				pGrid(r,c) = patch(c+[0 0 1 1],r+[0 1 1 0],[1 1 1],'EdgeColor',[0 0 1]);
				pGrid(r,c).UserData.filled = false;
				pGrid(r,c).UserData.x = false;
				pGrid(r,c).UserData.xT = text(c+0.5,r+0.5,'X','HorizontalAlignment','center','FontSize',20,'Visible','off');
			end
		end
		
		% add thick lines every 5 squares
		for i = 1:5:(n+1)
			line([i i],[1 n+1],'LineWidth',3,'Color',[0 0 1]); %vert
			line([1 n+1],[i i],'LineWidth',3,'Color',[0 0 1]); %hor
		end
		
		
		%add number text
		vText = matlab.graphics.primitive.Text.empty;
		hText = matlab.graphics.primitive.Text.empty;
		for i = 1:n
			if ~isempty(vertNums{i})
				str = {};
				for j = 1:length(vertNums{i})
					str{j,1} = num2str(vertNums{i}(j));
				end
				vText(i) = text(i+0.5,0.9,str,'VerticalAlignment','bottom');
			else
				
			end
			
			if ~isempty(horNums{i})
				hText(i) = text(0.9,i+0.5,num2str(horNums{i}),'HorizontalAlignment','right');
			else
				
			end
		end
		
% 		if ax.OuterPosition(4) > ax.Position(4)
% 			f.Position(4) = f.Position(4)*ax.OuterPosition(4)/ax.Position(4);
% 		end
% 		v = 
% 		if any(arrayfun(@(x) x.Extent(4),vText)>2)
% 			f.Position(4) = f.Position(4) + 10;
% % 			pause
% 		end
% 		s = get(0,'ScreenSize');
% 		if sum(f.Position([2,4])) > s(4)
% 			f.Position(2) = s(4) - sum(f.Position([2,4])) - 5;
% 		end
		axis([-1 n+1, -1.5 n+1])
	end
	
	function [] = randGen()
		%generate grid
		ansKey = randi(2,n)-1;
		if sum(sum(ansKey)) < (n^2)/2
			ansKey = ~ansKey;
		end
		ansKey = [zeros(n,1), [zeros(1,n-1); randi(2,n-1,n-1)-1]];
		
		% get numbers
		vertNums = {};
		horNums = {};
		for i = 1:n
			% go down a column
			j = 1;
			ind = 1;
			vertNums{i} = [];
			while j <= n
				c = 0;
				while j<=n && ansKey(j,i)
					c = c + 1;
					j = j + 1;
				end
				if c~=0
					vertNums{i}(ind) = c; % change to cell, edit array in each, a{1}(2) works
					ind = ind + 1;
				end
				j = j + 1;
			end
			if isempty(vertNums{i})
				vertNums{i} = 0;
			end
			
			
			% go right a row
			j = 1;
			ind = 1;
			horNums{i} = [];
			while j <= n
				c = 0;
				while j<=n && ansKey(i,j)
					c = c + 1;
					j = j + 1;
				end
				if c~=0
					horNums{i}(ind) = c;
					ind = ind + 1;
				end
				j = j + 1;
			end
			if isempty(horNums{i})
				horNums{i} = 0;
			end
		end
		
				%test
% 		vertNums{:}
% 		horNums{:}
	end
	
	function [] = figureSetup()
		f = figure(1);
		clf
		f.MenuBar = 'none';
		f.WindowButtonDownFcn = @click;
		f.Color = [1 1 1];
		
		ax = axes('Parent',f);
		ax.XTick = [];
		ax.YTick = [];
		ax.YDir = 'reverse';
		axis equal
		ax.Color = f.Color;
		ax.YColor = f.Color;
		ax.XColor = f.Color;
		ax.Position(1) = 0.175;%1-ax.Position(3)-0.05;
		ax.Position(3) = 0.775;
		ax.Position(2) = 0.05;
		ax.Position(4) = 0.9;%0.8;
		
		ng = uicontrol(...
			'Parent',f,...
			'Style','pushbutton',...
			'String','New Game',...
			'Units','normalized',...
			'Position',[0.05 0.45 0.1 0.1],...
			'FontSize',14,...
			'Callback',@newGame);
		
% 		asdf = nan*ones(16);
% 		asdf([1,18,19,20,34,35,37,38,50,52,53,55,67,68,69,70,72,83,85,86,87,89,100,102,103,104,106,117,119,120,121,123,134,136,137,138,140,151,153,154,155,157,168,170,171,172,174,185,187,188,189,191,202,204,205,206,208,219,221,222,223,224,236,238,239,253,254]) = 1;
% 		asdf([36,51,54,71,84,88,101,105,118,122,135,139,152,156,169,173,186,190,203,207,220,234]) = 2;
% 		f.Pointer = 'custom';
% 		f.PointerShapeCData = asdf;
	end
	
end

