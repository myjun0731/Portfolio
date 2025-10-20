
(() => {
    "use strict";

    // 전역 변수들
    const mindmapState = {
        nodes: new Map(),
        connections: new Map(),
        selectedNodes: new Set(),
        clipboard: null,
        currentMode: 'select', // select, connect, pan
        zoom: 1.0,
        panX: 0,
        panY: 0,
        isDirty: false,
        nodeIdCounter: 5,
        connectionIdCounter: 1
    };

    const history = {
        undoStack: [],
        redoStack: [],
        limit: 50
    };

    let isRestoringHistory = false;

    const DEFAULT_FILE_NAME = '새 마인드맵.mindmap';

    const projectExplorerState = {
        treeData: [
            {
                id: 'project-root',
                name: 'MindMap Project',
                type: 'folder',
                icon: '📁',
                expanded: true,
                children: [
                    {
                        id: 'folder-mindmap',
                        name: '마인드맵',
                        type: 'folder',
                        icon: '📁',
                        expanded: true,
                        children: [
                            {
                                id: 'file-new-map',
                                name: DEFAULT_FILE_NAME,
                                type: 'file',
                                icon: '🗺️',
                                fileName: DEFAULT_FILE_NAME
                            },
                            {
                                id: 'file-project-plan',
                                name: '프로젝트 계획.mindmap',
                                type: 'file',
                                icon: '🗺️',
                                fileName: '프로젝트 계획.mindmap'
                            }
                        ]
                    },
                    {
                        id: 'folder-templates',
                        name: '템플릿',
                        type: 'folder',
                        icon: '📁',
                        expanded: false,
                        children: [
                            {
                                id: 'file-meeting-template',
                                name: '회의 템플릿.mindmap',
                                type: 'file',
                                icon: '🗺️',
                                fileName: '회의 템플릿.mindmap'
                            }
                        ]
                    }
                ]
            }
        ],
        selectedId: 'file-new-map',
        filter: ''
    };

    // UI 상태 객체에 dragStartPos 추가
    const ui = {
        canvas: null,
        ctx: null,
        minimapCanvas: null,
        minimapCtx: null,
        isDragging: false,
        isConnecting: false,
        dragStartNode: null,
        dragStartPos: null, // 드래그 시작 위치 추가
        dragOffset: { x: 0, y: 0 },
        connectFrom: null,
        lastMousePos: { x: 0, y: 0 },
        didMoveNodes: false
    };

    // DOM 요소 참조
    const canvas = document.getElementById('mindmap-canvas');
    const minimapCanvas = document.getElementById('minimap-canvas');
    const consoleOutput = document.getElementById('console');
    const contextMenu = document.getElementById('context-menu');
    const body = document.body;
    const modalOverlay = document.getElementById('app-modal');
    const modalTitle = document.getElementById('modal-title');
    const modalBody = document.getElementById('modal-body');
    const toastStack = document.getElementById('toast-stack');
    const autosaveIndicator = document.getElementById('autosave-indicator');
    const editorEmptyState = document.getElementById('editor-empty-state');

    const GRID_BASE_SIZE = 20;
    const THEME_STORAGE_KEY = 'collamind-theme';

    const themePalette = {
        nodeBaseBg: '#1f1f1f',
        nodeBaseText: '#f5f5f5',
        nodeBaseBorder: '#3a3a3a',
        nodeRootBg: '#f5f5f5',
        nodeRootText: '#080808',
        nodeRootBorder: '#d0d0d0',
        gridColor: 'rgba(255, 255, 255, 0.06)',
        edgeColor: '#666666',
        minimapBackground: '#1f1f1f',
        minimapNode: '#3a3a3a',
        minimapRoot: '#f5f5f5',
        danger: '#f25c5c'
    };

    function readCssVar(styles, name, fallback) {
        const value = styles.getPropertyValue(name).trim();
        return value || fallback;
    }

    function refreshThemePalette() {
        const previous = { ...themePalette };
        const styles = body ? getComputedStyle(body) : getComputedStyle(document.documentElement);
        themePalette.nodeBaseBg = readCssVar(styles, '--node-base-bg', themePalette.nodeBaseBg);
        themePalette.nodeBaseText = readCssVar(styles, '--node-base-text', themePalette.nodeBaseText);
        themePalette.nodeBaseBorder = readCssVar(styles, '--node-base-border', themePalette.nodeBaseBorder);
        themePalette.nodeRootBg = readCssVar(styles, '--node-root-bg', themePalette.nodeRootBg);
        themePalette.nodeRootText = readCssVar(styles, '--node-root-text', themePalette.nodeRootText);
        themePalette.nodeRootBorder = readCssVar(styles, '--node-root-border', themePalette.nodeRootBorder);
        themePalette.gridColor = readCssVar(styles, '--grid-color', themePalette.gridColor);
        themePalette.edgeColor = readCssVar(styles, '--accent-border', themePalette.edgeColor);
        themePalette.minimapBackground = readCssVar(styles, '--surface-1', themePalette.minimapBackground);
        themePalette.minimapNode = readCssVar(styles, '--node-base-border', themePalette.minimapNode);
        themePalette.minimapRoot = readCssVar(styles, '--node-root-bg', themePalette.minimapRoot);
        themePalette.danger = readCssVar(styles, '--danger', themePalette.danger);
        return previous;
    }

    function normalizeColor(value) {
        if (!value) return '';
        const trimmed = value.trim().toLowerCase();
        if (trimmed.startsWith('#')) {
            return trimmed;
        }
        const match = trimmed.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
        if (match) {
            const [, r, g, b] = match;
            const toHex = num => Number.parseInt(num, 10).toString(16).padStart(2, '0');
            return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
        }
        return trimmed;
    }

    function colorsEqual(a, b) {
        return normalizeColor(a) === normalizeColor(b);
    }

    function applyGridBackground() {
        if (!canvas) return;
        canvas.style.backgroundImage = `radial-gradient(circle, ${themePalette.gridColor} 1px, transparent 1px)`;
        canvas.style.backgroundSize = `${GRID_BASE_SIZE}px ${GRID_BASE_SIZE}px`;
        canvas.dataset.grid = 'on';
    }

    function syncNodeElementStyle(node) {
        if (!node.element) return;
        const defaults = getDefaultStyle(node.isRoot);
        if (colorsEqual(node.style.backgroundColor, defaults.backgroundColor)) {
            node.element.style.backgroundColor = '';
        } else {
            node.element.style.backgroundColor = node.style.backgroundColor;
        }
        if (colorsEqual(node.style.color, defaults.color)) {
            node.element.style.color = '';
        } else {
            node.element.style.color = node.style.color;
        }
        if (colorsEqual(node.style.borderColor, defaults.borderColor)) {
            node.element.style.borderColor = '';
        } else {
            node.element.style.borderColor = node.style.borderColor;
        }
        node.element.style.fontSize = `${node.style.fontSize}px`;
    }

    function updateNodesForThemeChange(previousPalette) {
        mindmapState.nodes.forEach(node => {
            if (!node.style) {
                node.style = { ...getDefaultStyle(node.isRoot) };
            }
            const currentDefaults = getDefaultStyle(node.isRoot);
            const prevDefaults = node.isRoot
                ? {
                    backgroundColor: previousPalette.nodeRootBg,
                    color: previousPalette.nodeRootText,
                    borderColor: previousPalette.nodeRootBorder
                }
                : {
                    backgroundColor: previousPalette.nodeBaseBg,
                    color: previousPalette.nodeBaseText,
                    borderColor: previousPalette.nodeBaseBorder
                };

            const matchesPreviousDefaults = colorsEqual(node.style.backgroundColor, prevDefaults.backgroundColor) &&
                colorsEqual(node.style.color, prevDefaults.color) &&
                colorsEqual(node.style.borderColor, prevDefaults.borderColor);

            if (matchesPreviousDefaults) {
                node.style = { ...node.style, ...currentDefaults };
            }

            applyStyleToNode(node, {});
        });
    }

    let selectionBox = null;
    let selectionStart = null;
    let isSelecting = false;

    // 좌표 변환 유틸리티
    function worldToScreen(x, y) {
        return {
            x: x * mindmapState.zoom + mindmapState.panX,
            y: y * mindmapState.zoom + mindmapState.panY
        };
    }

    function screenToWorld(x, y) {
        return {
            x: (x - mindmapState.panX) / mindmapState.zoom,
            y: (y - mindmapState.panY) / mindmapState.zoom
        };
    }

    function applyNodePosition(node) {
        if (!node || !node.element) return;
        const { x, y } = worldToScreen(node.x, node.y);
        node.element.style.left = `${x}px`;
        node.element.style.top = `${y}px`;
        node.element.style.transform = `scale(${mindmapState.zoom})`;
    }

    function applyAllNodePositions() {
        mindmapState.nodes.forEach(node => applyNodePosition(node));
        updateCanvasBackground();
    }

    function updateCanvasBackground() {
        if (!canvas) return;
        const scaledSize = GRID_BASE_SIZE * mindmapState.zoom;
        canvas.style.backgroundSize = `${scaledSize}px ${scaledSize}px`;

        const offsetX = ((mindmapState.panX % scaledSize) + scaledSize) % scaledSize;
        const offsetY = ((mindmapState.panY % scaledSize) + scaledSize) % scaledSize;
        canvas.style.backgroundPosition = `${offsetX}px ${offsetY}px`;
    }

    function serializeState() {
        const nodes = Array.from(mindmapState.nodes.values()).map(node => ({
            id: node.id,
            text: node.text,
            x: node.x,
            y: node.y,
            parentId: node.parentId,
            isRoot: node.isRoot,
            style: { ...node.style }
        }));

        const connections = Array.from(mindmapState.connections.values()).map(conn => ({
            id: conn.id,
            from: conn.from,
            to: conn.to
        }));

        return JSON.stringify({
            nodes,
            connections,
            zoom: mindmapState.zoom,
            panX: mindmapState.panX,
            panY: mindmapState.panY,
            nodeIdCounter: mindmapState.nodeIdCounter,
            connectionIdCounter: mindmapState.connectionIdCounter,
            theme: body?.classList.contains('theme-light') ? 'light' : 'dark'
        });
    }

    function applyStateData(stateData) {
        const container = document.querySelector('.canvas-container');
        if (!container) return;

        document.querySelectorAll('.mind-node').forEach(node => node.remove());

        mindmapState.nodes.clear();
        mindmapState.connections.clear();
        mindmapState.selectedNodes.clear();

        mindmapState.zoom = typeof stateData.zoom === 'number' ? stateData.zoom : 1.0;
        mindmapState.panX = typeof stateData.panX === 'number' ? stateData.panX : 0;
        mindmapState.panY = typeof stateData.panY === 'number' ? stateData.panY : 0;

        if (body) {
            if (stateData.theme === 'light') {
                body.classList.add('theme-light');
            } else {
                body.classList.remove('theme-light');
            }
        }

        const anchor = container.querySelector('.zoom-controls');

        (stateData.nodes || []).forEach(nodeData => {
            const nodeElement = document.createElement('div');
            nodeElement.className = `mind-node ${nodeData.isRoot ? 'root' : ''}`;
            nodeElement.id = `node-${nodeData.id}`;
            nodeElement.dataset.id = nodeData.id;

            if (nodeData.parentId) {
                nodeElement.dataset.parent = nodeData.parentId;
            } else {
                delete nodeElement.dataset.parent;
            }

            nodeElement.textContent = nodeData.text;

            const style = nodeData.style ? { ...nodeData.style } : getDefaultStyle(nodeData.isRoot);
            if (typeof style.fontSize !== 'number') {
                style.fontSize = parseInt(style.fontSize, 10) || 14;
            }

            if (anchor) {
                container.insertBefore(nodeElement, anchor);
            } else {
                container.appendChild(nodeElement);
            }

            nodeElement.addEventListener('mousedown', onNodeMouseDown);
            nodeElement.addEventListener('dblclick', onNodeDoubleClick);

            const nodeRecord = {
                id: nodeData.id,
                text: nodeData.text,
                x: nodeData.x,
                y: nodeData.y,
                parentId: nodeData.parentId || null,
                element: nodeElement,
                isRoot: !!nodeData.isRoot,
                style: { ...style }
            };
            mindmapState.nodes.set(nodeData.id, nodeRecord);
            applyStyleToNode(nodeRecord, nodeRecord.style);
        });

        const maxNodeId = (stateData.nodes || []).reduce((max, node) => {
            const numeric = parseInt(node.id, 10);
            return Number.isFinite(numeric) ? Math.max(max, numeric) : max;
        }, 0);

        const nextNodeCounter = Number.isFinite(stateData.nodeIdCounter) ? stateData.nodeIdCounter : maxNodeId + 1;
        mindmapState.nodeIdCounter = Math.max(nextNodeCounter, maxNodeId + 1, 2);

        (stateData.connections || []).forEach(conn => {
            mindmapState.connections.set(conn.id, {
                id: conn.id,
                from: conn.from,
                to: conn.to
            });
        });

        const maxConnId = (stateData.connections || []).reduce((max, conn) => {
            const numeric = parseInt((conn.id || '').replace(/\D+/g, ''), 10);
            return Number.isFinite(numeric) ? Math.max(max, numeric) : max;
        }, 0);

        const nextConnCounter = Number.isFinite(stateData.connectionIdCounter) ? stateData.connectionIdCounter : maxConnId + 1;
        mindmapState.connectionIdCounter = Math.max(nextConnCounter, maxConnId + 1, 1);

        mindmapState.currentMode = 'select';
        setMode('select', { log: false });

        applyAllNodePositions();
        render();
        updateMinimap();
        updateUI();
    }

    function captureSnapshot(description = '') {
        if (isRestoringHistory) return;

        const serialized = serializeState();
        const last = history.undoStack[history.undoStack.length - 1];

        if (last && last.data === serialized) {
            last.description = description || last.description;
            last.dirty = mindmapState.isDirty;
            return;
        }

        history.undoStack.push({
            data: serialized,
            description,
            dirty: mindmapState.isDirty,
            timestamp: Date.now()
        });

        if (history.undoStack.length > history.limit) {
            history.undoStack.shift();
        }

        history.redoStack.length = 0;
    }

    function restoreSnapshot(snapshot) {
        if (!snapshot) return;

        try {
            isRestoringHistory = true;
            const data = JSON.parse(snapshot.data);
            applyStateData(data);
            setDirty(!!snapshot.dirty);
        } catch (error) {
            log('error', '상태 복원에 실패했습니다: ' + error.message);
        } finally {
            isRestoringHistory = false;
        }
    }

    function markChanged(description) {
        if (isRestoringHistory) return;
        setDirty(true);
        captureSnapshot(description);
    }

    // 초기화
    function init() {
        ui.canvas = canvas;
        ui.ctx = canvas.getContext('2d');
        ui.minimapCanvas = minimapCanvas;
        ui.minimapCtx = minimapCanvas.getContext('2d');

        if (modalOverlay) {
            modalOverlay.hidden = true;
            modalOverlay.setAttribute('aria-hidden', 'true');
        }

        loadThemePreference();
        refreshThemePalette();
        applyGridBackground();

        // 캔버스 크기 조정
        resizeCanvas();

        // 기존 노드들을 상태에 추가
        initializeNodes();

        // 현재 줌/팬 상태에 맞게 노드 위치 적용
        applyAllNodePositions();

        // 이벤트 리스너 등록
        setupEventListeners();

        // 초기 렌더링
        render();
        updateMinimap();
        updateUI();

        setDirty(false);
        captureSnapshot('초기 상태');
        updateEditorWorkspaceVisibility();

        log('info', '마인드맵 에디터가 완전히 초기화되었습니다.');
    }

    // 기존 노드들을 상태 객체에 등록
    function initializeNodes() {
        document.querySelectorAll('.mind-node').forEach(nodeEl => {
            const id = nodeEl.dataset.id;
            const parentId = nodeEl.dataset.parent || null;
            const computed = window.getComputedStyle(nodeEl);
            const defaults = getDefaultStyle(nodeEl.classList.contains('root'));
            const backgroundColor = normalizeColor(nodeEl.style.backgroundColor || computed.backgroundColor) || defaults.backgroundColor;
            const color = normalizeColor(nodeEl.style.color || computed.color) || defaults.color;
            const borderColor = normalizeColor(nodeEl.style.borderColor || computed.borderColor) || defaults.borderColor;
            const fontSize = parseInt(nodeEl.style.fontSize || computed.fontSize || defaults.fontSize, 10) || defaults.fontSize;

            const node = {
                id: id,
                text: nodeEl.textContent.trim(),
                x: parseInt(nodeEl.style.left),
                y: parseInt(nodeEl.style.top),
                parentId: parentId,
                element: nodeEl,
                isRoot: nodeEl.classList.contains('root'),
                style: {
                    backgroundColor,
                    color,
                    borderColor,
                    fontSize
                }
            };

            mindmapState.nodes.set(id, node);
            applyStyleToNode(node, {});

            // 연결 생성
            if (parentId && mindmapState.nodes.has(parentId)) {
                const connectionId = `conn-${parentId}-${id}`;
                mindmapState.connections.set(connectionId, {
                    id: connectionId,
                    from: parentId,
                    to: id
                });
            }
        });
    }

    // 캔버스 크기 조정
    function resizeCanvas() {
        const container = canvas.parentElement;
        canvas.width = container.clientWidth;
        canvas.height = container.clientHeight;
        render();
    }

    // 이벤트 리스너 설정
    function setupEventListeners() {
        // 창 크기 변경
        window.addEventListener('resize', resizeCanvas);

        // 캔버스 이벤트
        canvas.addEventListener('mousedown', onCanvasMouseDown);
        canvas.addEventListener('mousemove', onCanvasMouseMove);
        canvas.addEventListener('mouseup', onCanvasMouseUp);
        canvas.addEventListener('wheel', onCanvasWheel);
        canvas.addEventListener('contextmenu', onCanvasRightClick);

        // 노드 이벤트
        setupNodeEvents();

        // 키보드 이벤트
        document.addEventListener('keydown', onKeyDown);
        document.addEventListener('keyup', onKeyUp);

        // 메뉴 이벤트
        setupMenuEvents();

        // 툴바 이벤트
        setupToolbarEvents();

        // 속성 패널 이벤트
        setupPropertiesEvents();

        // 트리 이벤트
        setupTreeEvents();

        // 기타 UI 이벤트
        setupUIEvents();
    }

    // 노드 이벤트 설정
    function setupNodeEvents() {
        document.querySelectorAll('.mind-node').forEach(nodeEl => {
            nodeEl.addEventListener('mousedown', onNodeMouseDown);
            nodeEl.addEventListener('dblclick', onNodeDoubleClick);
        });
    }

    // 캔버스 마우스 다운
    function onCanvasMouseDown(e) {
        const rect = canvas.getBoundingClientRect();
        const pointer = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        ui.lastMousePos = { ...pointer };

        if (e.button === 0 && (e.ctrlKey || e.shiftKey)) {
            startSelection(pointer, e.ctrlKey || e.shiftKey);
            return;
        }

        if (mindmapState.currentMode === 'pan' || e.button === 1) { // 중간 마우스 버튼
            ui.isDragging = true;
            canvas.style.cursor = 'grabbing';
        }
    }

    // 캔버스 마우스 이동
    function onCanvasMouseMove(e) {
        const rect = canvas.getBoundingClientRect();
        const currentPos = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        if (ui.isDragging && (mindmapState.currentMode === 'pan' || e.buttons === 4)) {
            const deltaX = currentPos.x - ui.lastMousePos.x;
            const deltaY = currentPos.y - ui.lastMousePos.y;

            mindmapState.panX += deltaX;
            mindmapState.panY += deltaY;

            render();
            updateMinimap();
            applyAllNodePositions();
        }

        ui.lastMousePos = currentPos;
    }

    // 캔버스 마우스 업
    function onCanvasMouseUp() {
        ui.isDragging = false;
        canvas.style.cursor = mindmapState.currentMode === 'pan' ? 'grab' : 'crosshair';
    }

    function startSelection(startPoint, additiveSelection) {
        if (!canvas.parentElement) return;

        if (!additiveSelection) {
            clearSelection();
        }

        isSelecting = true;
        selectionStart = startPoint;

        selectionBox = document.createElement('div');
        selectionBox.className = 'selection-box';
        selectionBox.style.left = `${startPoint.x}px`;
        selectionBox.style.top = `${startPoint.y}px`;
        selectionBox.style.width = '0px';
        selectionBox.style.height = '0px';

        canvas.parentElement.appendChild(selectionBox);

        document.addEventListener('mousemove', onSelectionMouseMove);
        document.addEventListener('mouseup', onSelectionMouseUp);
    }

    function onSelectionMouseMove(e) {
        if (!isSelecting || !selectionStart) return;

        const rect = canvas.getBoundingClientRect();
        const current = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

        const x = Math.min(selectionStart.x, current.x);
        const y = Math.min(selectionStart.y, current.y);
        const width = Math.abs(selectionStart.x - current.x);
        const height = Math.abs(selectionStart.y - current.y);

        if (selectionBox) {
            selectionBox.style.left = `${x}px`;
            selectionBox.style.top = `${y}px`;
            selectionBox.style.width = `${width}px`;
            selectionBox.style.height = `${height}px`;
        }
    }

    function onSelectionMouseUp(e) {
        if (!isSelecting || !selectionStart) return;

        const boxRect = selectionBox?.getBoundingClientRect();
        if (boxRect) {
            document.querySelectorAll('.mind-node').forEach(nodeEl => {
                const nodeRect = nodeEl.getBoundingClientRect();
                const intersects = !(nodeRect.right < boxRect.left ||
                                     nodeRect.left > boxRect.right ||
                                     nodeRect.bottom < boxRect.top ||
                                     nodeRect.top > boxRect.bottom);
                if (intersects) {
                    selectNode(nodeEl.dataset.id);
                }
            });
        }

        if (selectionBox && selectionBox.parentElement) {
            selectionBox.parentElement.removeChild(selectionBox);
        }

        selectionBox = null;
        selectionStart = null;
        isSelecting = false;

        document.removeEventListener('mousemove', onSelectionMouseMove);
        document.removeEventListener('mouseup', onSelectionMouseUp);
    }

    // 캔버스 휠 (줌)
    function onCanvasWheel(e) {
        e.preventDefault();
        const zoomFactor = e.deltaY > 0 ? 0.9 : 1.1;
        setZoom(mindmapState.zoom * zoomFactor);
    }

    // 캔버스 우클릭
    function onCanvasRightClick(e) {
        e.preventDefault();
        showContextMenu(e.pageX, e.pageY);
    }

    // 노드 마우스 다운
    function onNodeMouseDown(e) {
        e.stopPropagation();
        const nodeId = e.target.dataset.id;

        if (mindmapState.currentMode === 'connect') {
            if (!ui.connectFrom) {
                ui.connectFrom = nodeId;
                e.target.style.borderColor = themePalette.danger;
                updateStatus('연결할 대상 노드를 선택하세요');
            } else if (ui.connectFrom !== nodeId) {
                createConnection(ui.connectFrom, nodeId);
                clearConnectMode();
            }
            return;
        }

        // 선택 처리
        if (!e.ctrlKey && !e.shiftKey) {
            clearSelection();
        }
        selectNode(nodeId);

        // 드래그 시작
        ui.isDragging = true;
        ui.dragStartNode = nodeId;
        ui.didMoveNodes = false;

        const containerRect = document.querySelector('.canvas-container').getBoundingClientRect();
        const pointerScreen = {
            x: e.clientX - containerRect.left,
            y: e.clientY - containerRect.top
        };
        const pointerWorld = screenToWorld(pointerScreen.x, pointerScreen.y);
        const startNode = mindmapState.nodes.get(nodeId);

        if (startNode) {
            ui.dragOffset = {
                x: pointerWorld.x - startNode.x,
                y: pointerWorld.y - startNode.y
            };
        } else {
            ui.dragOffset = { x: 0, y: 0 };
        }

        // 초기 마우스 위치 저장 (컨테이너 기준)
        ui.dragStartPos = pointerWorld;

        // 글로벌 마우스 이벤트 추가
        document.addEventListener('mousemove', onGlobalMouseMove);
        document.addEventListener('mouseup', onGlobalMouseUp);
    }

    // 노드 더블클릭 (편집 모드)
    function onNodeDoubleClick(e) {
        e.stopPropagation();
        const nodeId = e.target.dataset.id;
        startEditNode(nodeId);
    }

    // 글로벌 마우스 이동 (노드 드래그)
    function onGlobalMouseMove(e) {
        if (ui.isDragging && ui.dragStartNode) {
            const containerRect = document.querySelector('.canvas-container').getBoundingClientRect();

            // 현재 마우스 위치 (컨테이너 기준)
            const pointerScreen = {
                x: e.clientX - containerRect.left,
                y: e.clientY - containerRect.top
            };
            const pointerWorld = screenToWorld(pointerScreen.x, pointerScreen.y);

            // 새 노드 위치 계산 (오프셋 적용)
            const newX = pointerWorld.x - ui.dragOffset.x;
            const newY = pointerWorld.y - ui.dragOffset.y;

            // 드래그 시작 노드의 현재 위치
            const startNode = mindmapState.nodes.get(ui.dragStartNode);
            if (!startNode) return;

            // 이동 거리 계산
            const deltaX = newX - startNode.x;
            const deltaY = newY - startNode.y;

            if (deltaX !== 0 || deltaY !== 0) {
                // 선택된 모든 노드를 같은 거리만큼 이동
                moveSelectedNodes(deltaX, deltaY);
                ui.didMoveNodes = true;

                render();
                updateMinimap();
            }
        }
    }

    // 글로벌 마우스 업
    function onGlobalMouseUp(e) {
        if (ui.isDragging) {
            // 드래그 종료 시 willChange 속성 제거 (성능 최적화)
            mindmapState.selectedNodes.forEach(nodeId => {
                const node = mindmapState.nodes.get(nodeId);
                if (node && node.element) {
                    node.element.style.willChange = 'auto';
                }
            });
        }

        if (ui.didMoveNodes) {
            markChanged('노드 이동');
            ui.didMoveNodes = false;
        }

        ui.isDragging = false;
        ui.dragStartNode = null;
        ui.dragStartPos = null;
        document.removeEventListener('mousemove', onGlobalMouseMove);
        document.removeEventListener('mouseup', onGlobalMouseUp);
    }

    // 키보드 이벤트
    function onKeyDown(e) {
        if (isModalOpen()) {
            if (e.code === 'Escape') {
                e.preventDefault();
                closeModal();
            }
            return;
        }

        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

        switch(e.code) {
            case 'Delete':
                e.preventDefault();
                deleteSelectedNodes();
                break;
            case 'Insert':
                e.preventDefault();
                addNode();
                break;
            case 'Tab':
                e.preventDefault();
                if (mindmapState.selectedNodes.size === 1) {
                    addChildNode([...mindmapState.selectedNodes][0]);
                }
                break;
            case 'Enter':
                e.preventDefault();
                if (mindmapState.selectedNodes.size === 1) {
                    addSiblingNode([...mindmapState.selectedNodes][0]);
                }
                break;
            case 'Escape':
                e.preventDefault();
                if (mindmapState.currentMode === 'connect') {
                    clearConnectMode();
                } else {
                    setMode('select', { log: false });
                }
                clearSelection();
                hideContextMenu();
                closeAllMenus();
                break;
        }

        // Ctrl + 키 조합
        if (e.ctrlKey) {
            switch(e.code) {
                case 'KeyS':
                    e.preventDefault();
                    saveDocument();
                    break;
                case 'KeyN':
                    e.preventDefault();
                    newDocument();
                    break;
                case 'KeyO':
                    e.preventDefault();
                    openDocument();
                    break;
                case 'KeyZ':
                    e.preventDefault();
                    undo();
                    break;
                case 'KeyY':
                    e.preventDefault();
                    redo();
                    break;
                case 'KeyA':
                    e.preventDefault();
                    selectAllNodes();
                    break;
                case 'KeyC':
                    e.preventDefault();
                    copySelectedNodes();
                    break;
                case 'KeyV':
                    e.preventDefault();
                    pasteNodes();
                    break;
                case 'KeyX':
                    e.preventDefault();
                    cutSelectedNodes();
                    break;
                case 'Equal':
                    e.preventDefault();
                    zoomIn();
                    break;
                case 'Minus':
                    e.preventDefault();
                    zoomOut();
                    break;
                case 'Digit0':
                    e.preventDefault();
                    fitToView();
                    break;
            }
        }

        if (e.altKey && !e.ctrlKey) {
            switch(e.code) {
                case 'Digit1':
                    e.preventDefault();
                    togglePanel('left');
                    break;
                case 'Digit2':
                    e.preventDefault();
                    togglePanel('right');
                    break;
                case 'KeyM':
                    e.preventDefault();
                    setMode('pan');
                    break;
                case 'KeyS':
                    e.preventDefault();
                    setMode('select');
                    break;
                case 'KeyT':
                    e.preventDefault();
                    toggleTheme();
                    break;
                case 'Digit0':
                    e.preventDefault();
                    resetView();
                    break;
            }
        }
    }

    function onKeyUp(e) {
        // 키 업 이벤트 처리
    }

    // 메뉴 이벤트 설정
    function setupMenuEvents() {
        // 메뉴 항목 클릭
        document.querySelectorAll('.menu-item').forEach(item => {
            const dropdown = item.querySelector('.dropdown-menu');
            if (!dropdown) return;

            const showMenu = () => {
                closeAllMenus();
                dropdown.style.display = 'block';
            };

            item.addEventListener('mouseenter', showMenu);
            item.addEventListener('focusin', showMenu);
            item.addEventListener('click', function(e) {
                const isVisible = dropdown.style.display === 'block';
                if (isVisible) {
                    dropdown.style.display = 'none';
                } else {
                    showMenu();
                }
                e.stopPropagation();
            });
            item.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    const isVisible = dropdown.style.display === 'block';
                    if (isVisible) {
                        dropdown.style.display = 'none';
                    } else {
                        showMenu();
                    }
                }
            });
        });

        // 드롭다운 항목 클릭
        document.querySelectorAll('.dropdown-item').forEach(item => {
            item.addEventListener('click', function(e) {
                e.stopPropagation();
                const action = this.dataset.action;
                executeAction(action);
                closeAllMenus();
            });
            item.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    const action = this.dataset.action;
                    executeAction(action);
                    closeAllMenus();
                }
            });
        });
    }

    // 툴바 이벤트 설정
    function setupToolbarEvents() {
        document.querySelectorAll('.toolbar-button').forEach(btn => {
            btn.addEventListener('click', function() {
                const action = this.dataset.action;
                executeAction(action);
            });
        });
    }

    // 속성 패널 이벤트 설정
    function setupPropertiesEvents() {
        const propertyInputs = {
            'prop-text': updateNodeText,
            'prop-bgcolor': updateNodeBackgroundColor,
            'prop-color': updateNodeColor,
            'prop-fontsize': updateNodeFontSize,
            'prop-bordercolor': updateNodeBorderColor,
            'prop-x': updateNodeX,
            'prop-y': updateNodeY
        };

        Object.entries(propertyInputs).forEach(([id, handler]) => {
            const input = document.getElementById(id);
            if (input) {
                input.addEventListener('change', handler);
                input.addEventListener('input', handler);
            }
        });
    }

    // 트리 이벤트 설정
    function setupTreeEvents() {
        renderProjectTree();

        const searchInput = document.getElementById('project-search');
        const clearButton = document.getElementById('project-search-clear');

        if (searchInput) {
            searchInput.value = projectExplorerState.filter;
            searchInput.addEventListener('input', () => {
                projectExplorerState.filter = searchInput.value.trim();
                renderProjectTree();
            });
        }

        if (clearButton) {
            clearButton.addEventListener('click', () => {
                projectExplorerState.filter = '';
                if (searchInput) {
                    searchInput.value = '';
                    searchInput.focus();
                }
                renderProjectTree();
            });
        }

        updateProjectSearchUI();
    }

    function updateProjectSearchUI() {
        const searchInput = document.getElementById('project-search');
        const clearButton = document.getElementById('project-search-clear');

        if (!clearButton) return;

        if (searchInput && searchInput.value.trim().length > 0) {
            clearButton.classList.add('is-visible');
        } else {
            clearButton.classList.remove('is-visible');
        }
    }

    function renderProjectTree() {
        const container = document.getElementById('project-tree');
        if (!container) return;

        container.innerHTML = '';
        const fragment = document.createDocumentFragment();
        const filterText = (projectExplorerState.filter || '').trim().toLowerCase();
        let hasVisibleNodes = false;

        projectExplorerState.treeData.forEach(node => {
            const nodeFragment = createTreeNodeElement(node, 0, filterText);
            if (nodeFragment) {
                fragment.appendChild(nodeFragment);
                hasVisibleNodes = true;
            }
        });

        if (hasVisibleNodes) {
            container.appendChild(fragment);
        } else {
            const emptyMessage = document.createElement('div');
            emptyMessage.className = 'tree-empty';
            emptyMessage.textContent = filterText ? '검색 결과가 없습니다.' : '표시할 항목이 없습니다.';
            container.appendChild(emptyMessage);
        }

        updateProjectSearchUI();
    }

    function createTreeNodeElement(node, level, filterText) {
        const matchesFilter = !filterText || node.name.toLowerCase().includes(filterText) ||
            (node.fileName && node.fileName.toLowerCase().includes(filterText));

        const fragment = document.createDocumentFragment();
        const item = document.createElement('div');
        item.classList.add('tree-item');
        item.dataset.id = node.id;
        item.dataset.type = node.type;
        item.style.paddingLeft = `${level * 16}px`;

        if (projectExplorerState.selectedId === node.id) {
            item.classList.add('selected');
        }

        if (matchesFilter && filterText) {
            item.classList.add('match');
        }

        const icon = document.createElement('div');
        icon.classList.add('tree-icon');

        const childFragments = [];
        let visibleChildCount = 0;

        if (node.children && node.children.length > 0) {
            node.children.forEach(child => {
                const childFragment = createTreeNodeElement(child, level + 1, filterText);
                if (childFragment) {
                    childFragments.push(childFragment);
                    visibleChildCount++;
                }
            });
        }

        if (!matchesFilter && visibleChildCount === 0) {
            return null;
        }

        const isExpanded = filterText ? true : !!node.expanded;

        if (node.type === 'folder') {
            icon.classList.add(isExpanded ? 'expanded' : 'collapsed');
            icon.addEventListener('click', e => {
                e.stopPropagation();
                toggleFolder(node.id);
            });
        } else {
            icon.classList.add('spacer');
        }

        const label = document.createElement('span');
        label.classList.add('tree-label');
        label.textContent = `${node.icon} ${node.name}`;

        item.appendChild(icon);
        item.appendChild(label);

        if (node.type === 'folder') {
            item.addEventListener('click', () => {
                selectTreeItem(node.id);
            });
            item.addEventListener('dblclick', () => {
                toggleFolder(node.id);
            });
        } else {
            item.addEventListener('click', () => {
                selectTreeItem(node.id);
                openFile(node.fileName);
            });
        }

        fragment.appendChild(item);

        if (visibleChildCount > 0) {
            const childrenContainer = document.createElement('div');
            childrenContainer.classList.add('tree-children');
            childrenContainer.style.display = isExpanded ? 'flex' : 'none';

            childFragments.forEach(childFragment => {
                childrenContainer.appendChild(childFragment);
            });

            fragment.appendChild(childrenContainer);
        }

        return fragment;
    }

    function selectTreeItem(nodeId) {
        if (projectExplorerState.selectedId === nodeId) return;
        projectExplorerState.selectedId = nodeId;
        renderProjectTree();
    }

    function toggleFolder(nodeId) {
        const node = findTreeNode(nodeId, projectExplorerState.treeData);
        if (!node || node.type !== 'folder') return;
        node.expanded = !node.expanded;
        renderProjectTree();
    }

    function findTreeNode(nodeId, nodes) {
        for (const node of nodes) {
            if (node.id === nodeId) {
                return node;
            }
            if (node.children) {
                const found = findTreeNode(nodeId, node.children);
                if (found) {
                    return found;
                }
            }
        }
        return null;
    }

    function findTreePath(predicate, nodes, path = []) {
        for (const node of nodes) {
            const currentPath = [...path, node];
            if (predicate(node)) {
                return currentPath;
            }
            if (node.children) {
                const result = findTreePath(predicate, node.children, currentPath);
                if (result) {
                    return result;
                }
            }
        }
        return null;
    }

    function highlightProjectFile(filename) {
        const path = findTreePath(node => node.type === 'file' && node.fileName === filename, projectExplorerState.treeData);
        if (!path) return;

        path.forEach(node => {
            if (node.type === 'folder') {
                node.expanded = true;
            }
        });

        const fileNode = path[path.length - 1];
        projectExplorerState.selectedId = fileNode.id;
        renderProjectTree();
    }

    function setAllFoldersExpanded(nodes, expanded) {
        nodes.forEach(node => {
            if (node.type === 'folder') {
                node.expanded = expanded;
                if (node.children) {
                    setAllFoldersExpanded(node.children, expanded);
                }
            }
        });
    }

    function areAnyFoldersExpanded(nodes) {
        return nodes.some(node => {
            if (node.type === 'folder') {
                if (node.expanded) return true;
                if (node.children) {
                    return areAnyFoldersExpanded(node.children);
                }
            }
            return false;
        });
    }

    // UI 이벤트 설정
    function setupUIEvents() {
        document.querySelectorAll('.app-action[data-action]').forEach(btn => {
            btn.addEventListener('click', function() {
                executeAction(this.dataset.action);
            });
        });

        // 컨텍스트 메뉴
        document.querySelectorAll('.context-menu-item').forEach(item => {
            item.addEventListener('click', function() {
                const action = this.dataset.action;
                executeAction(action);
                hideContextMenu();
            });
            item.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    const action = this.dataset.action;
                    executeAction(action);
                    hideContextMenu();
                }
            });
        });

        // 줌 컨트롤
        document.querySelectorAll('.zoom-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const action = this.dataset.action;
                executeAction(action);
            });
        });

        // 패널 컨트롤
        document.querySelectorAll('.panel-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const action = this.dataset.action;
                executeAction(action);
            });
        });

        document.querySelectorAll('.status-item[data-action]').forEach(item => {
            item.addEventListener('click', function() {
                executeAction(this.dataset.action);
            });
            item.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    executeAction(this.dataset.action);
                }
            });
        });

        // 탭 및 닫기 버튼 이벤트 위임
        const tabsContainer = document.querySelector('.editor-tabs');
        if (tabsContainer) {
            tabsContainer.addEventListener('click', function(e) {
                const closeButton = e.target.closest('.close-btn');
                if (closeButton) {
                    e.stopPropagation();
                    const tab = closeButton.parentElement;
                    closeTab(tab);
                    return;
                }

                const tab = e.target.closest('.editor-tab');
                if (tab) {
                    activateTab(tab.dataset.file);
                }
            });
        }

        if (modalOverlay) {
            modalOverlay.addEventListener('click', function(e) {
                const actionTarget = e.target.closest('[data-action]');
                if (actionTarget && actionTarget.dataset.action === 'closemodal') {
                    executeAction('closemodal');
                    return;
                }

                if (e.target === modalOverlay) {
                    closeModal();
                }
            });
        }

        document.addEventListener('click', function(e) {
            if (!e.target.closest('.context-menu')) {
                hideContextMenu();
            }
            if (!e.target.closest('.menu-bar')) {
                closeAllMenus();
            }
        });
    }

    // 액션 실행
    function executeAction(action) {
        log('debug', `액션 실행: ${action}`);

        switch(action) {
            // 파일 작업
            case 'new': newDocument(); break;
            case 'open': openDocument(); break;
            case 'save': saveDocument(); break;
            case 'saveas': saveAsDocument(); break;
            case 'export': exportDocument(); break;
            case 'print': printDocument(); break;

            // 편집 작업
            case 'undo': undo(); break;
            case 'redo': redo(); break;
            case 'cut': cutSelectedNodes(); break;
            case 'copy': copySelectedNodes(); break;
            case 'paste': pasteNodes(); break;
            case 'delete': deleteSelectedNodes(); break;
            case 'selectall': selectAllNodes(); break;

            // 뷰 작업
            case 'zoomin': zoomIn(); break;
            case 'zoomout': zoomOut(); break;
            case 'zoomfit': fitToView(); break;
            case 'grid': toggleGrid(); break;
            case 'minimap': toggleMinimap(); break;

            // 노드 작업
            case 'addnode': addNode(); break;
            case 'addchild': addChildToSelected(); break;
            case 'addsibling': addSiblingToSelected(); break;
            case 'connect': toggleConnectMode(); break;

            // 기타
            case 'properties': showProperties(); break;
            case 'refresh': refreshProject(); break;
            case 'collapse': collapseProjectTree(); break;
            case 'clear': clearConsole(); break;
            case 'resetproperties': resetSelectedNodeStyles(); break;
            case 'toggleleftpanel': togglePanel('left'); break;
            case 'togglerightpanel': togglePanel('right'); break;
            case 'cyclemode': cycleMode(); break;
            case 'selectmode': setMode('select'); break;
            case 'panmode': setMode('pan'); break;
            case 'resetview': resetView(); break;
            case 'toggletheme': toggleTheme(); break;
            case 'showshortcuts': showShortcutsModal(); break;
            case 'showabout': showAboutModal(); break;
            case 'closemodal': closeModal(); break;
            case 'closetab': /* 탭별로 처리됨 */; break;

            default:
                log('warn', `알 수 없는 액션: ${action}`);
        }
    }

    // === 노드 관리 함수들 ===

    function selectNode(nodeId) {
        mindmapState.selectedNodes.add(nodeId);
        const node = mindmapState.nodes.get(nodeId);
        if (node && node.element) {
            node.element.classList.add('selected');
        }
        updateProperties();
        updateStatus(`선택: ${mindmapState.selectedNodes.size}개 노드`);
    }

    function clearSelection() {
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node && node.element) {
                node.element.classList.remove('selected');
            }
        });
        mindmapState.selectedNodes.clear();
        updateProperties();
        updateStatus('선택: 없음');
    }

    function deleteSelectedNodes() {
        if (mindmapState.selectedNodes.size === 0) return;

        let removedCount = 0;

        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node && !node.isRoot) { // 루트 노드는 삭제 불가
                // 연결 삭제
                mindmapState.connections.forEach((conn, connId) => {
                    if (conn.from === nodeId || conn.to === nodeId) {
                        mindmapState.connections.delete(connId);
                    }
                });

                // DOM에서 제거
                if (node.element) {
                    node.element.remove();
                }

                // 상태에서 제거
                mindmapState.nodes.delete(nodeId);
                removedCount += 1;
            }
        });

        clearSelection();
        render();
        updateMinimap();
        updateUI();
        if (removedCount > 0) {
            markChanged('노드 삭제');
            log('info', `${removedCount}개 노드가 삭제되었습니다.`);
        } else {
            log('warn', '루트 노드는 삭제할 수 없습니다.');
        }
    }

    function addNode() {
        const containerRect = document.querySelector('.canvas-container').getBoundingClientRect();
        const screenX = Math.random() * (containerRect.width - 200) + 100;
        const screenY = Math.random() * (containerRect.height - 200) + 100;
        const { x, y } = screenToWorld(screenX, screenY);

        createNode(`새 노드 ${mindmapState.nodeIdCounter}`, x, y);
        log('info', '새 노드가 추가되었습니다.');
        markChanged('노드 추가');
    }

    function addChildToSelected() {
        if (mindmapState.selectedNodes.size === 1) {
            const parentId = [...mindmapState.selectedNodes][0];
            addChildNode(parentId);
        }
    }

    function addSiblingToSelected() {
        if (mindmapState.selectedNodes.size === 1) {
            const siblingId = [...mindmapState.selectedNodes][0];
            addSiblingNode(siblingId);
        }
    }

    function addChildNode(parentId) {
        const parent = mindmapState.nodes.get(parentId);
        if (!parent) return;

        const x = parent.x + 150;
        const y = parent.y + 50;

        const childId = createNode(`하위 노드 ${mindmapState.nodeIdCounter}`, x, y, parentId);
        createConnection(parentId, childId, { trackHistory: false });
        log('info', '하위 노드가 추가되었습니다.');
        markChanged('하위 노드 추가');
    }

    function addSiblingNode(siblingId) {
        const sibling = mindmapState.nodes.get(siblingId);
        if (!sibling) return;

        const parentId = sibling.parentId;
        const x = sibling.x;
        const y = sibling.y + 80;

        const newSiblingId = createNode(`형제 노드 ${mindmapState.nodeIdCounter}`, x, y, parentId);
        if (parentId) {
            createConnection(parentId, newSiblingId, { trackHistory: false });
        }
        log('info', '형제 노드가 추가되었습니다.');
        markChanged('형제 노드 추가');
    }

    function createNode(text, x, y, parentId = null) {
        const nodeId = mindmapState.nodeIdCounter.toString();
        mindmapState.nodeIdCounter++;

        // DOM 요소 생성
        const nodeElement = document.createElement('div');
        nodeElement.className = 'mind-node';
        nodeElement.id = `node-${nodeId}`;
        nodeElement.dataset.id = nodeId;
        if (parentId) {
            nodeElement.dataset.parent = parentId;
        }
        nodeElement.textContent = text;

        // 컨테이너에 추가
        const container = document.querySelector('.canvas-container');
        if (container) {
            const anchor = container.querySelector('.zoom-controls');
            if (anchor) {
                container.insertBefore(nodeElement, anchor);
            } else {
                container.appendChild(nodeElement);
            }
        }

        // 이벤트 리스너 추가
        nodeElement.addEventListener('mousedown', onNodeMouseDown);
        nodeElement.addEventListener('dblclick', onNodeDoubleClick);

        // 상태에 추가
        const node = {
            id: nodeId,
            text: text,
            x: x,
            y: y,
            parentId: parentId,
            element: nodeElement,
            isRoot: false,
            style: { ...getDefaultStyle(false) }
        };

        mindmapState.nodes.set(nodeId, node);
        syncNodeElementStyle(node);

        applyNodePosition(node);

        render();
        updateMinimap();
        updateUI();

        return nodeId;
    }

    function moveSelectedNodes(deltaX, deltaY) {
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                // 새로운 위치로 업데이트
                node.x += deltaX;
                node.y += deltaY;

                // DOM 요소 즉시 업데이트 (부드러운 이동을 위해)
                if (node.element) {
                    applyNodePosition(node);
                    node.element.style.willChange = 'left, top';
                }
            }
        });

        // 속성 패널도 실시간 업데이트
        if (mindmapState.selectedNodes.size === 1) {
            const nodeId = [...mindmapState.selectedNodes][0];
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                const xInput = document.getElementById('prop-x');
                const yInput = document.getElementById('prop-y');
                if (xInput && yInput) {
                    xInput.value = Math.round(node.x);
                    yInput.value = Math.round(node.y);
                }
            }
        }
    }

    function startEditNode(nodeId) {
        const node = mindmapState.nodes.get(nodeId);
        if (!node || !node.element) return;

        node.element.classList.add('editing');
        const input = document.createElement('input');
        input.type = 'text';
        input.value = node.text;
        input.style.width = '100%';

        node.element.innerHTML = '';
        node.element.appendChild(input);
        input.focus();
        input.select();

        const finishEdit = () => {
            const newText = input.value.trim() || node.text;
            node.text = newText;
            node.element.textContent = newText;
            node.element.classList.remove('editing');
            markChanged('노드 텍스트 변경');
            log('info', `노드 텍스트가 변경되었습니다: "${newText}"`);
        };

        input.addEventListener('blur', finishEdit);
        input.addEventListener('keydown', (e) => {
            if (e.code === 'Enter') {
                e.preventDefault();
                finishEdit();
            } else if (e.code === 'Escape') {
                e.preventDefault();
                node.element.textContent = node.text;
                node.element.classList.remove('editing');
            }
        });
    }

    function createConnection(fromId, toId, options = {}) {
        const connectionId = `conn-${fromId}-${toId}`;
        if (mindmapState.connections.has(connectionId)) return;

        mindmapState.connections.set(connectionId, {
            id: connectionId,
            from: fromId,
            to: toId
        });

        render();
        updateMinimap();
        updateUI();
        if (options.trackHistory !== false) {
            markChanged('연결 추가');
        }
        log('info', `노드 ${fromId}과 ${toId} 사이에 연결이 생성되었습니다.`);
    }

    // === 렌더링 함수들 ===

    function render() {
        ui.ctx.clearRect(0, 0, canvas.width, canvas.height);

        // 변환 적용
        ui.ctx.save();
        ui.ctx.translate(mindmapState.panX, mindmapState.panY);
        ui.ctx.scale(mindmapState.zoom, mindmapState.zoom);

        // 연결선 그리기
        renderConnections();

        ui.ctx.restore();
    }

    function renderConnections() {
        ui.ctx.strokeStyle = themePalette.edgeColor;
        ui.ctx.lineWidth = 2;

        mindmapState.connections.forEach(connection => {
            const fromNode = mindmapState.nodes.get(connection.from);
            const toNode = mindmapState.nodes.get(connection.to);

            if (fromNode && toNode) {
                const fromX = fromNode.x + 60; // 노드 중심 추정
                const fromY = fromNode.y + 20;
                const toX = toNode.x + 60;
                const toY = toNode.y + 20;

                ui.ctx.beginPath();
                ui.ctx.moveTo(fromX, fromY);
                ui.ctx.lineTo(toX, toY);
                ui.ctx.stroke();
            }
        });
    }

    function updateMinimap() {
        if (!ui.minimapCtx) return;

        ui.minimapCtx.clearRect(0, 0, 200, 120);
        ui.minimapCtx.fillStyle = themePalette.minimapBackground;
        ui.minimapCtx.fillRect(0, 0, 200, 120);

        // 노드들을 미니맵에 그리기
        const scaleX = 200 / canvas.width;
        const scaleY = 120 / canvas.height;

        mindmapState.nodes.forEach(node => {
            const x = node.x * scaleX;
            const y = node.y * scaleY;

            ui.minimapCtx.fillStyle = node.isRoot ? themePalette.minimapRoot : themePalette.minimapNode;
            ui.minimapCtx.fillRect(x - 2, y - 1, 4, 2);
        });
    }

    // === UI 업데이트 함수들 ===

    function updateUI() {
        updateStatus();
        updateProperties();
        updateZoomDisplay();
    }

    function updateStatus(message = null) {
        if (message) {
            document.getElementById('status-mode').textContent = message;
        } else {
            document.getElementById('status-mode').textContent = mindmapState.currentMode === 'select' ? '선택 모드' : 
                                                                  mindmapState.currentMode === 'connect' ? '연결 모드' : 
                                                                  mindmapState.currentMode === 'pan' ? '이동 모드' : '선택 모드';
        }

        document.getElementById('status-selection').textContent = 
            mindmapState.selectedNodes.size === 0 ? '선택: 없음' : 
            mindmapState.selectedNodes.size === 1 ? `선택: 1개 노드` : 
            `선택: ${mindmapState.selectedNodes.size}개 노드`;

        document.getElementById('status-nodes').textContent = `노드: ${mindmapState.nodes.size}개`;
        document.getElementById('status-connections').textContent = `연결: ${mindmapState.connections.size}개`;
    }

    function updateProperties() {
        const selectedNodes = [...mindmapState.selectedNodes];

        if (selectedNodes.length === 0) {
            // 선택된 노드가 없을 때
            document.getElementById('prop-text').value = '';
            const defaults = getDefaultStyle(false);
            document.getElementById('prop-bgcolor').value = defaults.backgroundColor;
            document.getElementById('prop-color').value = defaults.color;
            document.getElementById('prop-fontsize').value = `${defaults.fontSize}`;
            document.getElementById('prop-bordercolor').value = defaults.borderColor;
            document.getElementById('prop-x').value = '0';
            document.getElementById('prop-y').value = '0';

            // 입력 필드 비활성화
            document.querySelectorAll('.property-input').forEach(input => {
                input.disabled = true;
            });
        } else if (selectedNodes.length === 1) {
            // 하나의 노드가 선택된 경우
            const node = mindmapState.nodes.get(selectedNodes[0]);
            if (node) {
                document.getElementById('prop-text').value = node.text;
                document.getElementById('prop-bgcolor').value = node.style.backgroundColor;
                document.getElementById('prop-color').value = node.style.color;
                document.getElementById('prop-fontsize').value = node.style.fontSize;
                document.getElementById('prop-bordercolor').value = node.style.borderColor;
                document.getElementById('prop-x').value = node.x;
                document.getElementById('prop-y').value = node.y;

                // 입력 필드 활성화
                document.querySelectorAll('.property-input').forEach(input => {
                    input.disabled = false;
                });
            }
        } else {
            // 여러 노드가 선택된 경우
            document.getElementById('prop-text').value = '(여러 개 선택됨)';
            document.getElementById('prop-x').value = '';
            document.getElementById('prop-y').value = '';

            // 공통 속성만 활성화
            document.querySelectorAll('.property-input').forEach(input => {
                input.disabled = input.id === 'prop-text' || input.id === 'prop-x' || input.id === 'prop-y';
            });
        }
    }

    function updateZoomDisplay() {
        const zoomPercent = Math.round(mindmapState.zoom * 100);
        const zoomIndicator = document.querySelector('.zoom-level');
        const statusZoom = document.getElementById('status-zoom');
        if (zoomIndicator) {
            zoomIndicator.textContent = `${zoomPercent}%`;
        }
        if (statusZoom) {
            statusZoom.textContent = `줌: ${zoomPercent}%`;
        }
    }

    function isModalOpen() {
        return modalOverlay && !modalOverlay.hidden;
    }

    function openModal(title, bodyHtml) {
        if (!modalOverlay || !modalTitle || !modalBody) return;
        modalTitle.textContent = title;
        modalBody.innerHTML = bodyHtml;
        modalOverlay.hidden = false;
        modalOverlay.setAttribute('aria-hidden', 'false');
        modalOverlay.focus?.();
    }

    function closeModal() {
        if (!modalOverlay || !modalBody) return;
        modalOverlay.hidden = true;
        modalOverlay.setAttribute('aria-hidden', 'true');
        modalBody.innerHTML = '';
    }

    function showShortcutsModal() {
        const shortcuts = `
            <div class="shortcut-grid">
                <p><strong>기본</strong></p>
                <ul>
                    <li>Ctrl + N : 새 마인드맵</li>
                    <li>Ctrl + O : 열기</li>
                    <li>Ctrl + S : 저장</li>
                    <li>Ctrl + P : 인쇄</li>
                </ul>
                <p><strong>편집</strong></p>
                <ul>
                    <li>Ctrl + Z / Y : 실행취소 / 다시실행</li>
                    <li>Ctrl + C / V / X : 복사 / 붙여넣기 / 잘라내기</li>
                    <li>Delete : 선택 노드 삭제</li>
                </ul>
                <p><strong>구조</strong></p>
                <ul>
                    <li>Insert : 새 노드 추가</li>
                    <li>Tab : 하위 노드 추가</li>
                    <li>Enter : 형제 노드 추가</li>
                    <li>Ctrl / Shift + 드래그 : 다중 선택 박스</li>
                </ul>
                <p><strong>보기 및 도구</strong></p>
                <ul>
                    <li>Ctrl + +/-/0 : 확대 / 축소 / 맞춤</li>
                    <li>Alt + 1 / 2 : 왼쪽 / 오른쪽 패널 토글</li>
                    <li>Alt + M / S : 이동 모드 / 선택 모드</li>
                    <li>Alt + 0 : 뷰 초기화</li>
                    <li>Alt + T : 테마 전환</li>
                </ul>
            </div>
        `;
        openModal('단축키 안내', shortcuts);
    }

    function showAboutModal() {
        const aboutHtml = `
            <p><strong>CollaMind</strong>는 협업을 위한 마인드맵 IDE 시연 버전입니다.</p>
            <ul>
                <li>드래그 앤 드롭, 다중 선택, 연결 모드 제공</li>
                <li>프로젝트 트리, 속성 패널, 미니맵, 콘솔 로그 지원</li>
                <li>JSON 내보내기 및 자동 저장을 통한 안전한 작업 흐름</li>
                <li>라이트/다크 테마 및 접근성 향상된 UI</li>
            </ul>
            <p>CollaMind를 통해 아이디어를 시각화하고 팀과 빠르게 공유하세요!</p>
        `;
        openModal('CollaMind 정보', aboutHtml);
    }

    // === 속성 업데이트 함수들 ===

    function updateNodeText(event) {
        const newText = event.target.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.text = newText;
                if (node.element) {
                    node.element.textContent = newText;
                }
            }
        });
        if (event.type === 'change') {
            markChanged('속성: 텍스트 변경');
        } else {
            setDirty(true);
        }
    }

    function updateNodeBackgroundColor(event) {
        const color = event.target.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                applyStyleToNode(node, { backgroundColor: color });
            }
        });
        if (event.type === 'change') {
            markChanged('속성: 배경색 변경');
        } else {
            setDirty(true);
        }
    }

    function updateNodeColor(event) {
        const color = event.target.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                applyStyleToNode(node, { color });
            }
        });
        if (event.type === 'change') {
            markChanged('속성: 글자색 변경');
        } else {
            setDirty(true);
        }
    }

    function updateNodeFontSize(event) {
        const fontSize = parseInt(event.target.value);
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                applyStyleToNode(node, { fontSize });
            }
        });
        if (event.type === 'change') {
            markChanged('속성: 글자 크기 변경');
        } else {
            setDirty(true);
        }
    }

    function updateNodeBorderColor(event) {
        const color = event.target.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                applyStyleToNode(node, { borderColor: color });
            }
        });
        if (event.type === 'change') {
            markChanged('속성: 테두리색 변경');
        } else {
            setDirty(true);
        }
    }

    function updateNodeX(event) {
        const newX = parseInt(event.target.value);
        if (mindmapState.selectedNodes.size === 1) {
            const nodeId = [...mindmapState.selectedNodes][0];
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.x = newX;
                applyNodePosition(node);
                render();
                updateMinimap();
            }
        }
        if (event.type === 'change') {
            markChanged('속성: X 좌표 변경');
        } else {
            setDirty(true);
        }
    }

    function updateNodeY(event) {
        const newY = parseInt(event.target.value);
        if (mindmapState.selectedNodes.size === 1) {
            const nodeId = [...mindmapState.selectedNodes][0];
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.y = newY;
                applyNodePosition(node);
                render();
                updateMinimap();
            }
        }
        if (event.type === 'change') {
            markChanged('속성: Y 좌표 변경');
        } else {
            setDirty(true);
        }
    }

    // === 문서 관리 함수들 ===

    function newDocument() {
        if (mindmapState.isDirty && !confirm('저장하지 않은 변경사항이 있습니다. 계속하시겠습니까?')) {
            return;
        }

        ensureTabForFile(DEFAULT_FILE_NAME);

        const container = document.querySelector('.canvas-container');
        const width = container ? container.clientWidth : 800;
        const height = container ? container.clientHeight : 600;

        const initialState = {
            nodes: [{
                id: '1',
                text: '중심 아이디어',
                x: width / 2 - 60,
                y: height / 2 - 20,
                parentId: null,
                isRoot: true,
                style: { ...getDefaultStyle(true) }
            }],
            connections: [],
            zoom: 1,
            panX: 0,
            panY: 0,
            nodeIdCounter: 2,
            connectionIdCounter: 1,
            theme: body?.classList.contains('theme-light') ? 'light' : 'dark'
        };

        isRestoringHistory = true;
        applyStateData(initialState);
        isRestoringHistory = false;

        history.undoStack.length = 0;
        history.redoStack.length = 0;
        setDirty(false);
        captureSnapshot('새 문서');
        log('info', '새 문서가 생성되었습니다.');
        showToast('새 마인드맵을 시작했습니다.', 'info');
    }

    function saveDocument() {
        // 실제 구현에서는 서버로 데이터 전송
        updateAutosaveIndicator('saving', '저장 중…');
        const data = exportToJSON();
        localStorage.setItem('mindmap-autosave', data);
        setDirty(false);
        const lastSnapshot = history.undoStack[history.undoStack.length - 1];
        if (lastSnapshot) {
            lastSnapshot.dirty = false;
        }
        log('info', '문서가 저장되었습니다.');
        showToast('문서가 저장되었습니다.', 'success');
    }

    function saveAsDocument() {
        const suggestedName = '마인드맵.json';
        const fileName = prompt('저장할 파일 이름을 입력하세요.', suggestedName);
        if (!fileName) {
            log('warn', '저장이 취소되었습니다.');
            showToast('저장이 취소되었습니다.', 'warn');
            return;
        }

        updateAutosaveIndicator('saving', '저장 중…');
        const downloadName = fileName.toLowerCase().endsWith('.json') ? fileName : `${fileName}.json`;
        const data = exportToJSON();
        const blob = new Blob([data], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = downloadName;
        anchor.click();
        URL.revokeObjectURL(url);
        setDirty(false);
        const lastSnapshot = history.undoStack[history.undoStack.length - 1];
        if (lastSnapshot) {
            lastSnapshot.dirty = false;
        }
        log('info', `문서가 "${downloadName}" 파일로 저장되었습니다.`);
        showToast(`"${downloadName}"(으)로 저장했습니다.`, 'success');
    }

    function openDocument() {
        // 실제 구현에서는 파일 선택 다이얼로그
        if (!hasOpenTabs()) {
            ensureTabForFile(DEFAULT_FILE_NAME);
        }

        const data = localStorage.getItem('mindmap-autosave');
        if (data) {
            importFromJSON(data);
            log('info', '문서가 열렸습니다.');
        } else {
            log('warn', '저장된 문서가 없습니다.');
            showToast('저장된 문서가 없습니다.', 'warn');
        }
    }

    function exportToJSON() {
        return JSON.stringify(JSON.parse(serializeState()), null, 2);
    }

    function importFromJSON(jsonData) {
        let data;
        try {
            data = JSON.parse(jsonData);
        } catch (error) {
            log('error', '문서 불러오기 실패: ' + error.message);
            showToast('문서를 불러오는 데 실패했습니다.', 'error');
            return;
        }

        const state = {
            nodes: data.nodes || [],
            connections: data.connections || [],
            zoom: typeof data.zoom === 'number' ? data.zoom : mindmapState.zoom,
            panX: typeof data.panX === 'number' ? data.panX : mindmapState.panX,
            panY: typeof data.panY === 'number' ? data.panY : mindmapState.panY,
            nodeIdCounter: data.nodeIdCounter,
            connectionIdCounter: data.connectionIdCounter,
            theme: data.theme || (body?.classList.contains('theme-light') ? 'light' : 'dark')
        };

        try {
            isRestoringHistory = true;
            applyStateData(state);
        } finally {
            isRestoringHistory = false;
        }

        setDirty(false);
        history.undoStack.length = 0;
        history.redoStack.length = 0;
        captureSnapshot('문서 불러오기');
        showToast('문서를 불러왔습니다.', 'success');
    }

    // === 줌 및 뷰 관리 ===

    function setZoom(newZoom) {
        mindmapState.zoom = Math.max(0.1, Math.min(5.0, newZoom));
        applyAllNodePositions();
        render();
        updateMinimap();
        updateZoomDisplay();
    }

    function zoomIn() {
        setZoom(mindmapState.zoom * 1.2);
    }

    function zoomOut() {
        setZoom(mindmapState.zoom / 1.2);
    }

    function fitToView() {
        if (mindmapState.nodes.size === 0) return;

        let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;

        mindmapState.nodes.forEach(node => {
            minX = Math.min(minX, node.x);
            minY = Math.min(minY, node.y);
            maxX = Math.max(maxX, node.x + 120); // 노드 폭 추정
            maxY = Math.max(maxY, node.y + 40);  // 노드 높이 추정
        });

        const contentWidth = maxX - minX;
        const contentHeight = maxY - minY;
        const padding = 50;

        const zoomX = (canvas.width - padding * 2) / contentWidth;
        const zoomY = (canvas.height - padding * 2) / contentHeight;
        const newZoom = Math.min(zoomX, zoomY, 1.0);

        mindmapState.zoom = newZoom;
        mindmapState.panX = padding - minX * newZoom + (canvas.width - contentWidth * newZoom) / 2;
        mindmapState.panY = padding - minY * newZoom + (canvas.height - contentHeight * newZoom) / 2;

        setZoom(newZoom);
    }

    // === 연결 모드 관리 ===

    function toggleConnectMode() {
        if (mindmapState.currentMode === 'connect') {
            clearConnectMode();
        } else {
            setMode('connect');
        }
    }

    function clearConnectMode() {
        mindmapState.currentMode = 'select';
        ui.connectFrom = null;
        canvas.style.cursor = 'crosshair';
        const connectBtn = document.querySelector('[data-action="connect"]');
        connectBtn?.classList.remove('active');

        // 연결 대기 중인 노드 스타일 복원
        document.querySelectorAll('.mind-node').forEach(node => {
            if (normalizeColor(node.style.borderColor) === normalizeColor(themePalette.danger)) {
                const nodeData = mindmapState.nodes.get(node.dataset.id);
                if (nodeData) {
                    syncNodeElementStyle(nodeData);
                }
            }
        });

        updateStatus();
        log('info', '연결 모드가 해제되었습니다.');
    }

    // === 클립보드 관리 ===

    function copySelectedNodes() {
        if (mindmapState.selectedNodes.size === 0) return;

        const copiedNodes = [];
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                copiedNodes.push({
                    text: node.text,
                    style: {...node.style},
                    isRoot: node.isRoot
                });
            }
        });

        mindmapState.clipboard = copiedNodes;
        log('info', `${copiedNodes.length}개 노드가 복사되었습니다.`);
    }

    function cutSelectedNodes() {
        copySelectedNodes();
        deleteSelectedNodes();
        log('info', '선택된 노드가 잘라내기되었습니다.');
    }

    function pasteNodes() {
        if (!mindmapState.clipboard || mindmapState.clipboard.length === 0) return;

        clearSelection();
        mindmapState.clipboard.forEach((clipNode, index) => {
            const screenX = 100 + index * 20;
            const screenY = 100 + index * 20;
            const { x, y } = screenToWorld(screenX, screenY);
            const nodeId = createNode(clipNode.text, x, y);

            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.style = { ...clipNode.style };
                node.isRoot = false; // 붙여넣은 노드는 루트가 될 수 없음
                applyStyleToNode(node, {});
                selectNode(nodeId);
            }
        });

        markChanged('노드 붙여넣기');
        log('info', `${mindmapState.clipboard.length}개 노드가 붙여넣기되었습니다.`);
    }

    function selectAllNodes() {
        clearSelection();
        mindmapState.nodes.forEach((node, nodeId) => {
            selectNode(nodeId);
        });
        log('info', '모든 노드가 선택되었습니다.');
    }

    // === 기타 유틸리티 함수들 ===

    function togglePanel(side) {
        const panelSelector = side === 'right' ? '.right-panel' : '.left-panel';
        const panel = document.querySelector(panelSelector);
        if (!panel) return;

        const collapsed = panel.classList.toggle('collapsed');
        const label = side === 'right' ? '오른쪽' : '왼쪽';
        log('info', `${label} 패널이 ${collapsed ? '숨겨졌습니다.' : '표시되었습니다.'}`);
    }

    function setMode(mode, options = {}) {
        if (!['select', 'pan', 'connect'].includes(mode)) return;

        const connectBtn = document.querySelector('[data-action="connect"]');

        if (mode !== 'connect' && mindmapState.currentMode === 'connect') {
            clearConnectMode();
        }

        if (mode === 'connect') {
            mindmapState.currentMode = 'connect';
            canvas.style.cursor = 'crosshair';
            connectBtn?.classList.add('active');
            updateStatus(options.message ?? '연결 모드: 첫 번째 노드를 선택하세요');
            if (options.log !== false) {
                log('info', '연결 모드가 활성화되었습니다.');
            }
            return;
        }

        mindmapState.currentMode = mode;
        connectBtn?.classList.remove('active');
        canvas.style.cursor = mode === 'pan' ? 'grab' : 'crosshair';
        updateStatus();
        if (options.log !== false) {
            log('info', mode === 'pan' ? '이동 모드가 활성화되었습니다.' : '선택 모드가 활성화되었습니다.');
        }
    }

    function cycleMode() {
        if (mindmapState.currentMode === 'pan') {
            setMode('select');
        } else {
            setMode('pan');
        }
    }

    function resetView() {
        mindmapState.panX = 0;
        mindmapState.panY = 0;
        setZoom(1.0);
        markChanged('뷰 초기화');
        updateStatus('뷰를 초기화했습니다.');
        log('info', '뷰가 초기화되었습니다.');
    }

    function getDefaultStyle(isRoot) {
        if (isRoot) {
            return {
                backgroundColor: normalizeColor(themePalette.nodeRootBg) || '#f5f5f5',
                color: normalizeColor(themePalette.nodeRootText) || '#080808',
                borderColor: normalizeColor(themePalette.nodeRootBorder) || '#d0d0d0',
                fontSize: 14
            };
        }
        return {
            backgroundColor: normalizeColor(themePalette.nodeBaseBg) || '#1f1f1f',
            color: normalizeColor(themePalette.nodeBaseText) || '#f5f5f5',
            borderColor: normalizeColor(themePalette.nodeBaseBorder) || '#3a3a3a',
            fontSize: 14
        };
    }

    function applyStyleToNode(node, style) {
        node.style = { ...node.style, ...style };
        node.style.backgroundColor = normalizeColor(node.style.backgroundColor) || node.style.backgroundColor;
        node.style.color = normalizeColor(node.style.color) || node.style.color;
        node.style.borderColor = normalizeColor(node.style.borderColor) || node.style.borderColor;
        node.style.fontSize = typeof node.style.fontSize === 'number' ? node.style.fontSize : parseInt(node.style.fontSize, 10) || 14;
        syncNodeElementStyle(node);
    }

    function resetSelectedNodeStyles() {
        if (mindmapState.selectedNodes.size === 0) {
            log('warn', '선택한 노드가 없습니다.');
            return;
        }

        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                const defaults = getDefaultStyle(node.isRoot);
                applyStyleToNode(node, defaults);
            }
        });

        updateProperties();
        markChanged('노드 스타일 초기화');
        log('info', '선택한 노드의 스타일을 초기화했습니다.');
    }

    function toggleTheme() {
        if (!body) return;
        const isLight = body.classList.toggle('theme-light');
        try {
            localStorage.setItem(THEME_STORAGE_KEY, isLight ? 'light' : 'dark');
        } catch (error) {
            log('warn', '테마 설정을 저장하지 못했습니다.');
        }
        const previousPalette = refreshThemePalette();
        if (canvas && canvas.dataset.grid !== 'off') {
            applyGridBackground();
        }
        updateNodesForThemeChange(previousPalette);
        render();
        updateMinimap();
        updateProperties();
        markChanged('테마 전환');
        log('info', `테마가 ${isLight ? '라이트' : '다크'} 모드로 변경되었습니다.`);
    }

    function loadThemePreference() {
        if (!body) return;
        try {
            const saved = localStorage.getItem(THEME_STORAGE_KEY);
            if (saved === 'light') {
                body.classList.add('theme-light');
            }
        } catch (error) {
            log('warn', '저장된 테마를 불러오지 못했습니다.');
        }
    }

    function closeAllMenus() {
        document.querySelectorAll('.dropdown-menu').forEach(menu => {
            menu.style.display = 'none';
        });
    }

    function setDirty(dirty) {
        mindmapState.isDirty = dirty;
        const tab = document.querySelector('.editor-tab.active');
        if (tab) {
            if (dirty) {
                tab.classList.add('modified');
            } else {
                tab.classList.remove('modified');
            }
        }

        updateAutosaveIndicator(dirty ? 'dirty' : 'saved', dirty ? '수정됨' : '저장됨');
    }

    function showContextMenu(x, y) {
        closeAllMenus();
        contextMenu.style.display = 'block';
        contextMenu.style.left = x + 'px';
        contextMenu.style.top = y + 'px';

        // 화면 밖으로 나가지 않도록 조정
        const rect = contextMenu.getBoundingClientRect();
        if (rect.right > window.innerWidth) {
            contextMenu.style.left = (x - rect.width) + 'px';
        }
        if (rect.bottom > window.innerHeight) {
            contextMenu.style.top = (y - rect.height) + 'px';
        }
    }

    function hideContextMenu() {
        contextMenu.style.display = 'none';
    }

    function showToast(message, level = 'info') {
        if (!toastStack || !message) return;

        const toast = document.createElement('div');
        toast.className = `toast toast-${level}`;
        toast.textContent = message;

        while (toastStack.children.length >= 5) {
            const first = toastStack.firstElementChild || toastStack.firstChild;
            if (!first) {
                break;
            }
            toastStack.removeChild(first);
        }

        toastStack.appendChild(toast);

        requestAnimationFrame(() => {
            toast.classList.add('visible');
        });

        const duration = level === 'error' ? 5200 : 3600;
        setTimeout(() => {
            toast.classList.remove('visible');
            setTimeout(() => {
                toast.remove();
            }, 250);
        }, duration);
    }

    function updateAutosaveIndicator(state, label) {
        if (!autosaveIndicator) return;

        if (state) {
            autosaveIndicator.dataset.state = state;
        } else {
            autosaveIndicator.removeAttribute('data-state');
        }

        if (label) {
            autosaveIndicator.textContent = label;
            return;
        }

        switch (state) {
            case 'dirty':
                autosaveIndicator.textContent = '수정됨';
                break;
            case 'saving':
                autosaveIndicator.textContent = '저장 중…';
                break;
            default:
                autosaveIndicator.textContent = '저장됨';
        }
    }

    function hasOpenTabs() {
        const tabsContainer = document.querySelector('.editor-tabs');
        return !!(tabsContainer && tabsContainer.querySelector('.editor-tab'));
    }

    function updateEditorWorkspaceVisibility() {
        const container = canvas?.parentElement;
        const hasTabs = hasOpenTabs();

        if (container) {
            container.classList.toggle('is-hidden', !hasTabs);
            container.setAttribute('aria-hidden', (!hasTabs).toString());
        }

        if (editorEmptyState) {
            editorEmptyState.classList.toggle('is-visible', !hasTabs);
            editorEmptyState.setAttribute('aria-hidden', hasTabs ? 'true' : 'false');
        }
    }

    function log(level, message) {
        const logEntry = document.createElement('div');
        logEntry.className = `log-${level}`;
        const timestamp = new Date().toLocaleTimeString();
        logEntry.innerHTML = `[${level.toUpperCase()}] ${timestamp} - ${message}`;
        consoleOutput.appendChild(logEntry);
        consoleOutput.scrollTop = consoleOutput.scrollHeight;
    }

    function clearConsole() {
        consoleOutput.innerHTML = '';
        log('info', '콘솔이 지워졌습니다.');
    }

    // === 추가 기능들 ===

    function undo() {
        if (history.undoStack.length <= 1) {
            log('warn', '실행취소할 변경사항이 없습니다.');
            return;
        }

        const current = history.undoStack.pop();
        history.redoStack.push(current);

        const snapshot = history.undoStack[history.undoStack.length - 1];
        restoreSnapshot(snapshot);
        log('info', `실행취소: ${current.description || '이전 상태로 돌아갔습니다.'}`);
    }

    function redo() {
        if (history.redoStack.length === 0) {
            log('warn', '다시실행할 변경사항이 없습니다.');
            return;
        }

        const snapshot = history.redoStack.pop();
        history.undoStack.push(snapshot);
        restoreSnapshot(snapshot);
        log('info', `다시실행: ${snapshot.description || '최근 실행취소를 되돌렸습니다.'}`);
    }

    function toggleGrid() {
        if (!canvas) return;
        const isOff = canvas.dataset.grid === 'off' || canvas.style.backgroundImage === 'none' || !canvas.style.backgroundImage;
        if (isOff) {
            applyGridBackground();
            log('info', '격자가 표시되었습니다.');
        } else {
            canvas.style.backgroundImage = 'none';
            canvas.dataset.grid = 'off';
            log('info', '격자가 숨겨졌습니다.');
        }
    }

    function toggleMinimap() {
        const minimap = document.querySelector('.minimap');
        if (minimap.style.display === 'none') {
            minimap.style.display = 'block';
            log('info', '미니맵이 표시되었습니다.');
        } else {
            minimap.style.display = 'none';
            log('info', '미니맵이 숨겨졌습니다.');
        }
    }

    function exportDocument() {
        const data = exportToJSON();
        const blob = new Blob([data], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = '마인드맵.json';
        a.click();
        URL.revokeObjectURL(url);
        log('info', '마인드맵이 JSON 파일로 내보내기되었습니다.');
    }

    function printDocument() {
        window.print();
        log('info', '인쇄 대화상자가 열렸습니다.');
    }

    function ensureTabForFile(filename, options = {}) {
        const { activate = true } = options;
        const tabsContainer = document.querySelector('.editor-tabs');
        if (!tabsContainer) return null;

        let tab = tabsContainer.querySelector(`.editor-tab[data-file="${filename}"]`);
        if (!tab) {
            tab = document.createElement('div');
            tab.classList.add('editor-tab');
            tab.dataset.file = filename;
            tab.innerHTML = `🗺️ ${filename} <span class="close-btn" data-action="closetab">×</span>`;
            tabsContainer.appendChild(tab);
        }

        if (activate) {
            activateTab(filename);
        }

        updateEditorWorkspaceVisibility();
        return tab;
    }

    function activateTab(filename) {
        const tabsContainer = document.querySelector('.editor-tabs');
        if (!tabsContainer) return;

        let targetTab = null;
        tabsContainer.querySelectorAll('.editor-tab').forEach(tab => {
            if (tab.dataset.file === filename) {
                targetTab = tab;
                tab.classList.add('active');
            } else {
                tab.classList.remove('active');
            }
        });

        if (targetTab) {
            highlightProjectFile(filename);
            updateStatus(`파일 열림: ${filename}`);
        }
    }

    function openFile(filename) {
        if (!filename) return;

        ensureTabForFile(filename);
        log('info', `파일 "${filename}"이 열렸습니다.`);
    }

    function closeTab(tab) {
        if (!tab) return;

        const isActive = tab.classList.contains('active');
        if (isActive && mindmapState.isDirty && !confirm('저장하지 않은 변경사항이 있습니다. 탭을 닫으시겠습니까?')) {
            return;
        }

        const tabsContainer = tab.parentElement;
        const closingFile = tab.dataset.file;
        tab.remove();
        log('info', '탭이 닫혔습니다.');

        if (tabsContainer) {
            const remaining = tabsContainer.querySelectorAll('.editor-tab');
            if (remaining.length > 0) {
                if (isActive) {
                    const fallback = remaining[remaining.length - 1];
                    if (fallback.dataset.file) {
                        activateTab(fallback.dataset.file);
                    } else {
                        fallback.classList.add('active');
                    }
                }
            } else {
                projectExplorerState.selectedId = null;
                renderProjectTree();
                setWorkspaceEmpty();
            }
        }

        if (!isActive && closingFile) {
            const activeTab = document.querySelector('.editor-tab.active');
            if (activeTab && activeTab.dataset.file) {
                highlightProjectFile(activeTab.dataset.file);
            }
        }

        updateEditorWorkspaceVisibility();
    }

    function setWorkspaceEmpty() {
        clearSelection();
        history.undoStack.length = 0;
        history.redoStack.length = 0;

        const theme = body?.classList.contains('theme-light') ? 'light' : 'dark';

        try {
            isRestoringHistory = true;
            applyStateData({
                nodes: [],
                connections: [],
                zoom: 1,
                panX: 0,
                panY: 0,
                nodeIdCounter: 1,
                connectionIdCounter: 1,
                theme
            });
        } finally {
            isRestoringHistory = false;
        }

        setDirty(false);
        updateStatus('파일 닫힘');
        updateEditorWorkspaceVisibility();
    }

    function collapseProjectTree() {
        const anyExpanded = areAnyFoldersExpanded(projectExplorerState.treeData);
        setAllFoldersExpanded(projectExplorerState.treeData, !anyExpanded);
        renderProjectTree();
        log('info', anyExpanded ? '모든 폴더가 접혔습니다.' : '모든 폴더가 확장되었습니다.');
    }

    function refreshProject() {
        renderProjectTree();
        const activeTab = document.querySelector('.editor-tab.active');
        if (activeTab) {
            highlightProjectFile(activeTab.dataset.file);
        }
        log('info', '프로젝트가 새로고침되었습니다.');
    }

    function showProperties() {
        const rightPanel = document.querySelector('.right-panel');
        if (!rightPanel) return;
        rightPanel.classList.remove('collapsed');
        rightPanel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        log('info', '속성 패널을 표시했습니다.');
    }

    // 자동 저장 (5분마다)
    setInterval(() => {
        if (mindmapState.isDirty) {
            const data = exportToJSON();
            localStorage.setItem('mindmap-autosave', data);
            log('debug', '자동 저장되었습니다.');
        }
    }, 300000); // 5분

    // === 초기화 실행 ===

    // DOM이 로드된 후 초기화
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

})();