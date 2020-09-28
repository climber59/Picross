%{
should the preview disappear if you move outside the puzzle?
- would make sense as the game doesn't fill anything that way

x's added by numDetect() may alter greying out of rows/cols that have
already been checked.
- running it twice would reduce the impact of this, but theoretically you
could have a chain of added x's causing added x's to other rows/cols
several times

number text shouldnt go off screen

with OnOffSwitchState, pGrid.UserData.x could be removed
- adds requirement of R2017a or later

undo button

numDetect() and randGen() have some repeated code about finding numbers
that could probably be turned into a function

numDetect() shouldn't have to check every row/column every mouseclick
- a single click could fill a whole row, so it will always have to check
many things

ui to change grid size
- allow rectangles?
%}
function [ ] = Picross( )
	f = [];
	ax = [];
	pGrid = [];
	vText = [];
	hText = [];
	
	preview = [];
	previewNum = [];
	
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
% 		vertNums
% 		horNums
		
% 		vertNums = {[3 2 1] [1 2 2 2] [3 1 2 2] [3 2 3] [4 3] [2 2 2] [1 1 3 1] [2 2 2 ] [1 1 4] [1 1 2 2] [1 1 2 3] [1 1 2 2] [1 1 2 1] [1 1 2 2] [1 1 2 4]};
% 		horNums = {[2] [1 8] [2 3] [1 3] [5 8] [2 4] [4 ] [3 3] [2 7] [1 6] [5 2] [4 2 2] [3 2 1] [3 2 1] [2 1 2 1]};

		
		build();
		numDetect();
		winner = false;
	end
	
	% checks if a row or column is completed and will fill in x's, dim the
	% hints, and check if the puzzle is completed
	function [] = numDetect()
		isMarked = @(y) y.UserData.filled || y.UserData.x;
		isFilled = @(y) y.UserData.filled;
		isXed = @(y) y.UserData.x;
		
% 		'remember to delete the clc'
% 		clc
		% get numbers
		cvertNums = cell(1,n);
		chorNums = cell(n,1);
		for i = 1:n
			% go down a column
			j = 1;
			ind = 1;
			cvertNums{i} = [];
			while j <= n
				c = 0;
				while j<=n && pGrid(j,i).UserData.filled
					c = c + 1;
					j = j + 1;
				end
				if c~=0
					cvertNums{i}(ind) = c;
					ind = ind + 1;
				elseif c == 0 && ind == 1
					
				end
				j = j + 1;
			end
			if isempty(cvertNums{i})
				cvertNums{i} = 0;
			end
			
			% go right a row
			j = 1;
			ind = 1;
			chorNums{i} = [];
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
			if isempty(chorNums{i})
				chorNums{i} = 0;
			end
		end
		
		%fill x's
		for i = 1:n
			% ===================== check col =====================
			if length(cvertNums{i})==length(vertNums{i}) && all(cvertNums{i} == vertNums{i}) % row/col matches clues
				for j = 1:n
					if ~isFilled(pGrid(j,i)) && ~isXed(pGrid(j,i))
						pGrid(j,i).UserData.x = true;
						pGrid(j,i).UserData.xT.Visible = 'on';
					end
				end
				for j = 1:length(vText{i})
					vText{i}(j).Color = 0.75*ones(1,3); % turn them all grey
				end
			elseif (length(cvertNums{i}) == length(vertNums{i}) && sum(cvertNums{i}) == sum(vertNums{i}) && ~all(cvertNums{i} == vertNums{i}))... % correct # of clusters and squares, but they don't match the clues
					|| all(arrayfun(isMarked,pGrid(:,i)))... % all filled, doesn't match
					|| (length(cvertNums{i}) > length(vertNums{i}) && sum(cvertNums{i}) >= sum(vertNums{i}))... % too many clusters
					|| sum(cvertNums{i}) > sum(vertNums{i})...  % too many squares filled
					|| (cvertNums{i}(1) == 0 && all(arrayfun(isXed,pGrid(:,i)))) % all 'x' when there should be squares
				for j = 1:length(vText{i})
					vText{i}(j).Color = [1 0 0]; % turn them all red
				end
			else % not all filled
				for j = 1:length(vText{i})
					vText{i}(j).Color = [0 0 0]; % assume black
				end
				j = 1;
				curNum = 1;
				while j <= n && isMarked(pGrid(j,i))
					count = 0;
					while j <= n && isFilled(pGrid(j,i))
						count = count + 1;
						j = j + 1;
					end
					if count == vertNums{i}(curNum)
						% add x, grey out
						vText{i}(curNum).Color = 0.75*ones(1,3);
						if j <= n % adding the x may make fixing mistakes harder
							pGrid(j,i).UserData.x = true;
							pGrid(j,i).UserData.xT.Visible = 'on';
						end
						curNum = curNum + 1;
					elseif count ~= 0 % stop if it doesn't match
						j = n + 1;
					else
						j = j + 1; % count == 0 when the square is an 'x'
					end
					
				end
				j = n; % check from the other direction now
				curNum = length(vertNums{i});
				while j >= 1 && isMarked(pGrid(j,i))
					count = 0;
					while j >= 1 && isFilled(pGrid(j,i))
						count = count + 1;
						j = j - 1;
					end
					if count == vertNums{i}(curNum)
						% add x, grey out
						vText{i}(curNum).Color = 0.75*ones(1,3);
						if j >= 1 % adding the x may make fixing mistakes harder for the user
							pGrid(j,i).UserData.x = true;
							pGrid(j,i).UserData.xT.Visible = 'on';
						end
						curNum = curNum - 1;
					elseif count ~= 0
						j = 0;
					else
						j = j - 1;
					end
				end
			end
			
			% ============================= check row =====================
			if length(chorNums{i})==length(horNums{i}) && all(chorNums{i} == horNums{i})
				for j = 1:n
					if ~pGrid(i,j).UserData.filled && ~pGrid(i,j).UserData.x
						pGrid(i,j).UserData.x = true;
						pGrid(i,j).UserData.xT.Visible = 'on';
					end
				end
				for j = 1:length(hText{i})
					hText{i}(j).Color = 0.75*ones(1,3); % grey out
				end
			elseif (length(chorNums{i})==length(horNums{i}) && sum(chorNums{i}) == sum(horNums{i})  && ~all(chorNums{i} == horNums{i}))... % correct # of clusters and squares, but they don't match the clues
					|| all(arrayfun(isMarked,pGrid(i,:)))... % all filled, doesn't match
					|| (length(chorNums{i}) > length(horNums{i}) && sum(chorNums{i}) >= sum(horNums{i}))... % too many "clusters"
					|| sum(chorNums{i}) > sum(horNums{i})...  % too many squares filled
					|| (chorNums{i}(1) == 0 && all(arrayfun(isXed,pGrid(i,:)))) % all 'x' when there should be squares
				for j = 1:length(hText{i})
					hText{i}(j).Color = [1 0 0];
				end
			else
				for j = 1:length(hText{i})
					hText{i}(j).Color = [0 0 0]; % assume black
				end
				j = 1;
				curNum = 1;
				while j <= n && isMarked(pGrid(i,j))
					count = 0;
					while j <= n && isFilled(pGrid(i,j))
						count = count + 1;
						j = j + 1;
					end
					if count == horNums{i}(curNum)
						% add x, grey out
						hText{i}(curNum).Color = 0.75*ones(1,3);
						if j <= n % adding the x may make fixing mistakes harder
							pGrid(i,j).UserData.x = true;
							pGrid(i,j).UserData.xT.Visible = 'on';
						end
						curNum = curNum + 1;
					elseif count ~= 0
						j = n + 1;
					else
						j = j + 1;
					end
				end
				j = n;
				curNum = length(horNums{i});
				while j >= 1 && isMarked(pGrid(i,j))
					count = 0;
					while j >= 1 && isFilled(pGrid(i,j))
						count = count + 1;
						j = j - 1;
					end
					if count == horNums{i}(curNum)
						% add x, grey out
						hText{i}(curNum).Color = 0.75*ones(1,3);
						if j >= 1 % adding the x may make fixing mistakes harder for the user
							pGrid(i,j).UserData.x = true;
							pGrid(i,j).UserData.xT.Visible = 'on';
						end
						curNum = curNum - 1;
					elseif count ~= 0
						j = 0;
					else
						j = j - 1;
					end
				end
			end
		end
	end
	
	% win check
	function [] = winCheck()
		isGrey = @(y) y.Color(1) == 0.75;
		winner = all(arrayfun(@(i) all(arrayfun(isGrey,vText{i})),1:n)) && all(arrayfun(@(i) all(arrayfun(isGrey,hText{i})),1:n)); % checks that all hints are greyed out
		if winner
			patch(1.5+(n-1)*[0 9 37 87 100 42]/100,1.5+(n-1)*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none');
		end
	end
	
	% stores mouse position on click
	function [] = mouseClick(~,~)
		if winner
			return
		end
		
		m = fliplr(floor(ax.CurrentPoint([1,3])));
		if any(m < 1) || any(m > n)
			return;
		end
		
		f.WindowButtonUpFcn = {@mouseRelease, m};
		f.WindowButtonMotionFcn = {@mouseMove, m};
	end
	
	% called as the mouse moves while dragging to fill
	function [] = mouseMove(~,~,m1)		
		% get second point, filter bad values
		m2 = fliplr(floor(ax.CurrentPoint([1,3]))); % row, col
		if any(m2 < 1) || any(m2 > n)
			if any(m2 < 0) || any(m2 > n+1)				
				preview.Visible = 'off';
				previewNum.Visible = 'off';
				return
			end
			m2 = min(max(m2,1),n);	
		end
		
		% pick which direction to fill
		[~,i] = max(abs(m1 - m2));
		if i == 1 % draw on a column
			r = [min(m1(1),m2(1)), max(m1(1),m2(1))];
			c = m1(2)*[1 1];
		else % draw on a row
			c = [min(m1(2),m2(2)), max(m1(2),m2(2))];
			r = m1(1)*[1 1];
		end
		num = 1 + max([abs(c(2) - c(1)), abs(r(2) - r(1))]);
		if num > 1 % only display if more than 1 square
			preview.XData = [1 1 3 3]/4 + [c(1) c(1) c(2) c(2)];
			preview.YData = [1 3 3 1]/4 + [r(1) r(2) r(2) r(1)];
			preview.Visible = 'on';
			if (i == 1 && m2(1) >= m1(1)) || (i ~= 1 && m2(2) >= m1(2)) % always puts the number at the end of the preview near the mouse
				previewNum.Position = 0.5 + [c(2) r(2)];
			else
				previewNum.Position = 0.5 + [c(1) r(1)];
			end
			previewNum.String = num2str(num);
			previewNum.Visible = 'on';
		else
			preview.Visible = 'off';
			previewNum.Visible = 'off';
		end
	end
	
	% called when the mouse is released
	function [] = mouseRelease(~,~,m1)
		f.WindowButtonUpFcn = [];
		f.WindowButtonMotionFcn = [];
		preview.Visible = 'off';
		previewNum.Visible = 'off';
		
		% get second point, filter bad values
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
			
			isMarked = @(y) y.UserData.filled || y.UserData.x;
			isFilled = @(y) y.UserData.filled;
			isXed = @(y) y.UserData.x;
			
			ind = sub2ind(size(pGrid),r,c);
			% fill
			switch f.SelectionType
				case 'normal'
					% add squares if any of the selected area is not square
					% remove squares if all are already filled
					if all(arrayfun(isFilled,pGrid(ind))) % all filled, remove
						for i = 1:length(ind)
							pGrid(ind(i)).FaceColor = [1 1 1];
							pGrid(ind(i)).UserData.filled = false;
						end
					else % add sqaures to any that aren't Xed
						ind = ind(~arrayfun(isXed,pGrid(ind)));
						for i = 1:length(ind)
							pGrid(ind(i)).FaceColor = [0 0 0];
							pGrid(ind(i)).UserData.filled = true;
						end
					end
				case 'alt'
					% add x if any of the selected area is not x
					% remove x if all are already xed
					if all(arrayfun(isXed,pGrid(ind))) % all Xed, remove
						for i = 1:length(ind)
							pGrid(ind(i)).UserData.x = false;
							pGrid(ind(i)).UserData.xT.Visible = 'off';
						end
					else % add X to any that aren't filled
						ind = ind(~arrayfun(isMarked,pGrid(ind)));
						for i = 1:length(ind)
							pGrid(ind(i)).UserData.x = true;
							pGrid(ind(i)).UserData.xT.Visible = 'on';
						end
					end
			end
		end
		
		numDetect();
		winCheck();
	end
	
	% creates the grid and clues
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
		vText = cell(1,n);
		hText = cell(1,n);
		for i = 1:n
			lv = length(vertNums{i});
			for j = 1:lv
				vText{i}(j) = text(i + 0.5,(j - lv + 1.5)*0.5,num2str(vertNums{i}(j)),'VerticalAlignment','bottom');
			end
			lh = length(horNums{i});
			for j = 1:lh
				hText{i}(j) = text((j - lh + 1.0)*0.5, i + 0.75,num2str(horNums{i}(j)),'VerticalAlignment','bottom');
			end
		end
		
		preview = patch([0 0 0 0],[0 0 0 0],[0.4 0.4 1], 'Visible','off','FaceAlpha',0.5','EdgeAlpha',0);
		previewNum = text(0,0,'0','Color',[1 1 1],'BackgroundColor',preview.FaceColor,'Visible','off','FontUnits','normalized','FontSize',1/(3*n),'HorizontalAlignment','center','Margin',eps);
		
		
		axis([-1 n+1, -1.5 n+1])
	end
	
	function [] = randGen()
		%generate grid
% 		ansKey = [zeros(1,n); zeros(n-1,1), randi(2,n-1,n-1) - 1]; % first row and col as 0, for testing special cases
		ansKey = randi(2,n)-1;
		if sum(sum(ansKey)) < (n^2)/2
			ansKey = ~ansKey;
		end
		
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
		f.WindowButtonDownFcn = @mouseClick;
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
		
		% makes the cursor look vaguely like a pencil
% 		asdf = nan*ones(16);
% 		asdf([1,18,19,20,34,35,37,38,50,52,53,55,67,68,69,70,72,83,85,86,87,89,100,102,103,104,106,117,119,120,121,123,134,136,137,138,140,151,153,154,155,157,168,170,171,172,174,185,187,188,189,191,202,204,205,206,208,219,221,222,223,224,236,238,239,253,254]) = 1;
% 		asdf([36,51,54,71,84,88,101,105,118,122,135,139,152,156,169,173,186,190,203,207,220,234]) = 2;
% 		f.Pointer = 'custom';
% 		f.PointerShapeCData = asdf;
	end
	
end

