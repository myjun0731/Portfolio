(function(global) {
    var draggedBlock = null;
    var movingBlock = null;
    var moveStartPos = { x: 0, y: 0 };
    var SNAP_GRID = 24;
    var SNAP_THRESHOLD = 28;
    var SNAP_GAP = 16;

    function initBlockly() {
        if (!global.AppState.workspaceBlocks) global.AppState.workspaceBlocks = [];
        renderWorkspaceBlocks();
        updateWorkspaceHint();
        if (global.lucide && global.lucide.createIcons) {
            global.lucide.createIcons();
        }
    }

    function dragStart(e) {
        var target = e.currentTarget || e.target;
        var blockType = target && target.dataset ? target.dataset.block : null;
        if (!blockType) return;

        draggedBlock = { type: blockType };

        var dragImage = target.cloneNode(true);
        dragImage.style.opacity = '0.7';
        document.body.appendChild(dragImage);
        e.dataTransfer.setDragImage(dragImage, 0, 0);
        setTimeout(function() { document.body.removeChild(dragImage); }, 0);

        var handleDragEnd = function() {
            toggleWorkspaceHover(false);
            draggedBlock = null;
            target.removeEventListener('dragend', handleDragEnd);
        };
        target.addEventListener('dragend', handleDragEnd);
    }

    function allowDrop(e) {
        e.preventDefault();
        toggleWorkspaceHover(true);
    }

    function workspaceDragEnter(e) {
        allowDrop(e);
    }

    function workspaceDragLeave(e) {
        if (e && e.currentTarget && e.relatedTarget && e.currentTarget.contains(e.relatedTarget)) {
            return;
        }
        toggleWorkspaceHover(false);
    }

    function toggleWorkspaceHover(active) {
        var workspace = document.getElementById('blockWorkspace');
        if (!workspace) return;
        if (active) workspace.classList.add('drag-hover');
        else workspace.classList.remove('drag-hover');
    }

    function createWorkspaceBlockElement(block) {
        var blockElement = document.createElement('div');
        blockElement.id = block.id;
        blockElement.className = 'block-workspace-item';
        blockElement.dataset.blockType = block.type;
        blockElement.style.left = (block.x || 0) + 'px';
        blockElement.style.top = (block.y || 0) + 'px';
        blockElement.setAttribute('draggable', 'true');

        var markup = block.content || getBlockMarkup(block.type);
        blockElement.innerHTML = '<div class="flex items-center justify-between gap-2">'+
                                 '<div class="flex-1">'+ markup +'</div>'+
                                 '<button type="button" class="workspace-remove" aria-label="블록 삭제">'+
                                 '<i data-lucide="x" class="h-4 w-4"></i>'+
                                 '</button>'+
                                 '</div>';

        blockElement.addEventListener('dragstart', function(event) { moveBlockStart(event, block.id); });
        blockElement.addEventListener('drag', function(event) { moveBlock(event, block.id); });
        blockElement.addEventListener('dragend', function(event) { moveBlockEnd(event, block.id); });

        var removeButton = blockElement.querySelector('.workspace-remove');
        if (removeButton) {
            removeButton.addEventListener('click', function() { removeBlock(block.id); });
        }

        return blockElement;
    }

    function getBlockMarkup(type) {
        var map = {
            'start': '▶ 시작하기 버튼을 클릭했을 때',
            'repeat-start': '▶ 무한 반복하기',
            'repeat': '<span class="block-input">10</span> 번 반복하기',
            'if': '만약 <span class="block-input">조건</span> 이라면',
            'wait': '<span class="block-input">1</span> 초 기다리기',
            'add': '<span class="block-input">0</span> + <span class="block-input">0</span>',
            'compare': '<span class="block-input">0</span> = <span class="block-input">0</span>',
            'random': '<span class="block-input">1</span> 부터 <span class="block-input">10</span> 사이의 난수',
            'set-var': '변수 <span class="block-input">이름</span> 을 <span class="block-input">0</span> (으)로 정하기',
            'change-var': '변수 <span class="block-input">이름</span> 을 <span class="block-input">1</span> 만큼 바꾸기',
            'print': '<span class="block-input">안녕!</span> 출력하기',
            'console': '콘솔에 <span class="block-input">값</span> 출력하기'
        };
        return map[type] || (type + ' 블록');
    }

    function getWorkspaceBlockRecord(blockId) {
        if (!global.AppState.workspaceBlocks) global.AppState.workspaceBlocks = [];
        for (var i = 0; i < global.AppState.workspaceBlocks.length; i++) {
            if (global.AppState.workspaceBlocks[i].id === blockId) return global.AppState.workspaceBlocks[i];
        }
        return null;
    }

    function updateWorkspaceState(blockId, payload) {
        if (!global.AppState.workspaceBlocks) global.AppState.workspaceBlocks = [];
        var record = getWorkspaceBlockRecord(blockId);
        if (record) {
            for (var key in payload) {
                if (Object.prototype.hasOwnProperty.call(payload, key)) {
                    record[key] = payload[key];
                }
            }
        }
    }

    function snapBlockPosition(blockElement) {
        if (!blockElement) return;
        var workspace = document.getElementById('blockWorkspace');
        if (!workspace) return;

        var left = parseInt(blockElement.style.left) || 0;
        var top = parseInt(blockElement.style.top) || 0;
        var width = blockElement.offsetWidth;
        var height = blockElement.offsetHeight;
        var workspaceWidth = workspace.clientWidth;
        var workspaceHeight = workspace.clientHeight;

        left = Math.round(left / SNAP_GRID) * SNAP_GRID;
        top = Math.round(top / SNAP_GRID) * SNAP_GRID;

        var blocks = Array.prototype.slice.call(workspace.querySelectorAll('.block-workspace-item')).filter(function(node) {
            return node.id !== blockElement.id;
        });

        blocks.forEach(function(other) {
            var otherLeft = parseInt(other.style.left) || 0;
            var otherTop = parseInt(other.style.top) || 0;
            var otherWidth = other.offsetWidth;
            var otherHeight = other.offsetHeight;

            var alignedVertically = Math.abs(otherLeft - left) <= SNAP_THRESHOLD;
            var alignedHorizontally = Math.abs(otherTop - top) <= SNAP_THRESHOLD;

            if (alignedVertically) {
                var snapBelow = otherTop + otherHeight + SNAP_GAP;
                var snapAbove = otherTop - height - SNAP_GAP;
                if (Math.abs(snapBelow - top) <= SNAP_THRESHOLD) {
                    top = snapBelow;
                    left = otherLeft;
                } else if (Math.abs(snapAbove - top) <= SNAP_THRESHOLD) {
                    top = snapAbove;
                    left = otherLeft;
                }
            }

            if (alignedHorizontally) {
                var snapRight = otherLeft + otherWidth + SNAP_GAP;
                var snapLeft = otherLeft - width - SNAP_GAP;
                if (Math.abs(snapRight - left) <= SNAP_THRESHOLD) {
                    left = snapRight;
                    top = otherTop;
                } else if (Math.abs(snapLeft - left) <= SNAP_THRESHOLD) {
                    left = snapLeft;
                    top = otherTop;
                }
            }
        });

        left = Math.round(left / SNAP_GRID) * SNAP_GRID;
        top = Math.round(top / SNAP_GRID) * SNAP_GRID;

        var iterations = 0;
        var adjusted = true;
        while (adjusted && iterations < 50) {
            adjusted = false;
            blocks.forEach(function(other) {
                var otherLeft = parseInt(other.style.left) || 0;
                var otherTop = parseInt(other.style.top) || 0;
                var otherWidth = other.offsetWidth;
                var otherHeight = other.offsetHeight;

                var overlapX = left < otherLeft + otherWidth && left + width > otherLeft;
                var overlapY = top < otherTop + otherHeight && top + height > otherTop;

                if (overlapX && overlapY) {
                    adjusted = true;
                    var below = otherTop + otherHeight + SNAP_GAP;
                    var above = otherTop - height - SNAP_GAP;
                    var right = otherLeft + otherWidth + SNAP_GAP;
                    var leftSide = otherLeft - width - SNAP_GAP;

                    if (below + height <= workspaceHeight) {
                        left = otherLeft;
                        top = below;
                    } else if (above >= 0) {
                        left = otherLeft;
                        top = above;
                    } else if (right + width <= workspaceWidth) {
                        left = right;
                        top = otherTop;
                    } else if (leftSide >= 0) {
                        left = leftSide;
                        top = otherTop;
                    } else {
                        left = Math.max(0, Math.min(left + SNAP_GRID, workspaceWidth - width));
                        top = Math.max(0, Math.min(top + SNAP_GRID, workspaceHeight - height));
                    }
                }
            });
            iterations++;
        }

        var maxLeft = Math.max(0, workspaceWidth - width);
        var maxTop = Math.max(0, workspaceHeight - height);

        left = Math.min(Math.max(0, left), maxLeft);
        top = Math.min(Math.max(0, top), maxTop);

        blockElement.classList.add('snapped');
        blockElement.style.left = left + 'px';
        blockElement.style.top = top + 'px';

        setTimeout(function() { blockElement.classList.remove('snapped'); }, 200);

        updateWorkspaceState(blockElement.id, {
            x: left,
            y: top,
            width: width,
            height: height
        });
    }

    function drop(e) {
        e.preventDefault();
        if (!draggedBlock) return;

        var workspace = document.getElementById('blockWorkspace');
        if (!workspace) return;

        var rect = workspace.getBoundingClientRect();
        var x = e.clientX - rect.left;
        var y = e.clientY - rect.top;

        var blockId = 'block_' + Date.now();
        var blockContent = getBlockMarkup(draggedBlock.type);

        if (!global.AppState.workspaceBlocks) global.AppState.workspaceBlocks = [];

        var blockData = {
            id: blockId,
            type: draggedBlock.type,
            x: x,
            y: y,
            content: blockContent
        };

        global.AppState.workspaceBlocks.push(blockData);

        var blockElement = createWorkspaceBlockElement(blockData);
        workspace.appendChild(blockElement);
        if (global.lucide && global.lucide.createIcons) {
            global.lucide.createIcons();
        }

        requestAnimationFrame(function() {
            snapBlockPosition(blockElement);
            updateBlockCount();
            updateWorkspaceHint();
        });

        draggedBlock = null;
        toggleWorkspaceHover(false);

        global.showToast('블록이 추가되었습니다', 'success');
    }

    function moveBlockStart(e, blockId) {
        movingBlock = document.getElementById(blockId);
        if (!movingBlock) return;

        var rect = movingBlock.getBoundingClientRect();
        var workspace = document.getElementById('blockWorkspace');
        var workspaceRect = workspace.getBoundingClientRect();

        moveStartPos = {
            x: e.clientX - (rect.left - workspaceRect.left),
            y: e.clientY - (rect.top - workspaceRect.top)
        };

        movingBlock.classList.add('dragging');
        toggleWorkspaceHover(true);
    }

    function moveBlock(e, blockId) {
        if (!movingBlock) return;
        e.preventDefault();
        toggleWorkspaceHover(true);

        var workspace = document.getElementById('blockWorkspace');
        var rect = workspace.getBoundingClientRect();

        var x = e.clientX - rect.left - moveStartPos.x;
        var y = e.clientY - rect.top - moveStartPos.y;

        x = Math.max(0, Math.min(x, rect.width - movingBlock.offsetWidth));
        y = Math.max(0, Math.min(y, rect.height - movingBlock.offsetHeight));

        movingBlock.style.left = x + 'px';
        movingBlock.style.top = y + 'px';
    }

    function moveBlockEnd() {
        if (movingBlock) {
            movingBlock.classList.remove('dragging');
            snapBlockPosition(movingBlock);
            updateBlockCount();
            updateWorkspaceHint();
        }
        movingBlock = null;
        toggleWorkspaceHover(false);
    }

    function removeBlock(blockId) {
        var block = document.getElementById(blockId);
        if (block) {
            block.remove();
            if (global.AppState.workspaceBlocks) {
                global.AppState.workspaceBlocks = global.AppState.workspaceBlocks.filter(function(b) {
                    return b.id !== blockId;
                });
            }
            updateBlockCount();
            updateWorkspaceHint();
            global.showToast('블록이 제거되었습니다', 'success');
        }
    }

    function updateBlockCount() {
        if (!global.AppState.workspaceBlocks) global.AppState.workspaceBlocks = [];

        var count = 0;
        global.AppState.workspaceBlocks.forEach(function(block) {
            if (block.type === 'repeat') count += 3;
            else if (block.type === 'if') count += 2;
            else count += 1;
        });

        global.AppState.blockCount = Math.max(count, global.AppState.workspaceBlocks.length * 2);

        var el = document.getElementById('stepCount');
        if (el) el.textContent = global.AppState.blockCount;
    }

    function updateWorkspaceHint() {
        var hint = document.getElementById('workspaceHint');
        var workspace = document.getElementById('blockWorkspace');
        var hasBlocks = global.AppState.workspaceBlocks && global.AppState.workspaceBlocks.length > 0;

        if (hint) {
            if (hasBlocks) hint.classList.add('hidden');
            else hint.classList.remove('hidden');
        }

        if (workspace) {
            if (hasBlocks) workspace.classList.add('workspace-filled');
            else workspace.classList.remove('workspace-filled');
        }
    }

    function renderWorkspaceBlocks() {
        var workspace = document.getElementById('blockWorkspace');
        if (!workspace) return;

        workspace.querySelectorAll('.block-workspace-item').forEach(function(node) {
            node.remove();
        });

        if (!global.AppState.workspaceBlocks) global.AppState.workspaceBlocks = [];

        var fragment = document.createDocumentFragment();
        global.AppState.workspaceBlocks.forEach(function(block, index) {
            if (!block.id) block.id = 'block_' + Date.now() + '_' + index;
            block.content = block.content || getBlockMarkup(block.type);
            if (typeof block.x !== 'number') block.x = SNAP_GRID * (index % 4);
            if (typeof block.y !== 'number') block.y = SNAP_GRID * 2 * Math.floor(index / 4);

            var element = createWorkspaceBlockElement(block);
            fragment.appendChild(element);
        });

        workspace.appendChild(fragment);
        if (global.lucide && global.lucide.createIcons) {
            global.lucide.createIcons();
        }

        requestAnimationFrame(function() {
            workspace.querySelectorAll('.block-workspace-item').forEach(function(node) {
                snapBlockPosition(node);
            });
            updateBlockCount();
            updateWorkspaceHint();
        });
    }

    function addBlockToWorkspace(type) {
        global.showToast(type+' 블록 (드래그 앤 드롭 사용)', 'success');
    }

    function searchBlocks() {
        var searchInput = document.getElementById('blockSearch');
        if (!searchInput) return;
        var q = searchInput.value.toLowerCase();
        var items = document.querySelectorAll('#blockPalette .block-item');
        var categories = document.querySelectorAll('#blockPalette .block-palette-category');

        items.forEach(function(el) {
            var text = el.textContent.toLowerCase();
            var show = text.indexOf(q) !== -1;
            el.style.display = show ? 'block' : 'none';
        });

        categories.forEach(function(cat) {
            var visibleBlocks = cat.querySelectorAll('.block-item:not([style*="display: none"])');
            cat.style.display = visibleBlocks.length > 0 ? 'block' : 'none';
        });
    }

    function clearWorkspace() {
        if (confirm('작업 공간을 초기화하시겠습니까?')) {
            global.AppState.workspaceBlocks = [];
            global.AppState.blockCount = 0;
            renderWorkspaceBlocks();
            updateBlockCount();
            updateWorkspaceHint();
            global.showToast('초기화 완료', 'success');
        }
    }

    global.initBlockly = initBlockly;
    global.dragStart = dragStart;
    global.allowDrop = allowDrop;
    global.workspaceDragEnter = workspaceDragEnter;
    global.workspaceDragLeave = workspaceDragLeave;
    global.drop = drop;
    global.moveBlockStart = moveBlockStart;
    global.moveBlock = moveBlock;
    global.moveBlockEnd = moveBlockEnd;
    global.removeBlock = removeBlock;
    global.updateBlockCount = updateBlockCount;
    global.updateWorkspaceHint = updateWorkspaceHint;
    global.renderWorkspaceBlocks = renderWorkspaceBlocks;
    global.addBlockToWorkspace = addBlockToWorkspace;
    global.searchBlocks = searchBlocks;
    global.clearWorkspace = clearWorkspace;
})(window);
