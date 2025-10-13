
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
                                name: '새 마인드맵.mindmap',
                                type: 'file',
                                icon: '🗺️',
                                fileName: '새 마인드맵.mindmap'
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
        selectedId: 'file-new-map'
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
        lastMousePos: { x: 0, y: 0 }
    };

    // DOM 요소 참조
    const canvas = document.getElementById('mindmap-canvas');
    const minimapCanvas = document.getElementById('minimap-canvas');
    const consoleOutput = document.getElementById('console');
    const contextMenu = document.getElementById('context-menu');
    const GRID_BASE_SIZE = 20;

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

    // 초기화
    function init() {
        ui.canvas = canvas;
        ui.ctx = canvas.getContext('2d');
        ui.minimapCanvas = minimapCanvas;
        ui.minimapCtx = minimapCanvas.getContext('2d');

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

        log('info', '마인드맵 에디터가 완전히 초기화되었습니다.');
    }

    // 기존 노드들을 상태 객체에 등록
    function initializeNodes() {
        document.querySelectorAll('.mind-node').forEach(nodeEl => {
            const id = nodeEl.dataset.id;
            const parentId = nodeEl.dataset.parent || null;
            const rect = nodeEl.getBoundingClientRect();
            const containerRect = document.querySelector('.canvas-container').getBoundingClientRect();

            const node = {
                id: id,
                text: nodeEl.textContent.trim(),
                x: parseInt(nodeEl.style.left),
                y: parseInt(nodeEl.style.top),
                parentId: parentId,
                element: nodeEl,
                isRoot: nodeEl.classList.contains('root'),
                style: {
                    backgroundColor: nodeEl.classList.contains('root') ? '#0e7db8' : '#505050',
                    color: '#ffffff',
                    borderColor: nodeEl.classList.contains('root') ? '#1890d9' : '#666666',
                    fontSize: 14
                }
            };

            mindmapState.nodes.set(id, node);

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
        ui.lastMousePos = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };

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
    function onCanvasMouseUp(e) {
        ui.isDragging = false;
        canvas.style.cursor = mindmapState.currentMode === 'pan' ? 'grab' : 'crosshair';
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
                e.target.style.borderColor = '#ff6b6b';
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

            // 선택된 모든 노드를 같은 거리만큼 이동
            moveSelectedNodes(deltaX, deltaY);

            render();
            updateMinimap();
            setDirty(true);
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

        ui.isDragging = false;
        ui.dragStartNode = null;
        ui.dragStartPos = null;
        document.removeEventListener('mousemove', onGlobalMouseMove);
        document.removeEventListener('mouseup', onGlobalMouseUp);
    }

    // 키보드 이벤트
    function onKeyDown(e) {
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
                clearConnectMode();
                clearSelection();
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
    }

    function onKeyUp(e) {
        // 키 업 이벤트 처리
    }

    // 메뉴 이벤트 설정
    function setupMenuEvents() {
        // 메뉴 항목 클릭
        document.querySelectorAll('.menu-item').forEach(item => {
            item.addEventListener('mouseenter', function() {
                // 다른 메뉴 닫기
                document.querySelectorAll('.dropdown-menu').forEach(menu => {
                    menu.style.display = 'none';
                });
                // 현재 메뉴 열기
                const dropdown = this.querySelector('.dropdown-menu');
                if (dropdown) {
                    dropdown.style.display = 'block';
                }
            });
        });

        // 메뉴바 밖을 클릭하면 메뉴 닫기
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.menu-bar')) {
                document.querySelectorAll('.dropdown-menu').forEach(menu => {
                    menu.style.display = 'none';
                });
            }
        });

        // 드롭다운 항목 클릭
        document.querySelectorAll('.dropdown-item').forEach(item => {
            item.addEventListener('click', function() {
                const action = this.dataset.action;
                executeAction(action);
                document.querySelectorAll('.dropdown-menu').forEach(menu => {
                    menu.style.display = 'none';
                });
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
    }

    function renderProjectTree() {
        const container = document.getElementById('project-tree');
        if (!container) return;

        container.innerHTML = '';
        const fragment = document.createDocumentFragment();

        projectExplorerState.treeData.forEach(node => {
            fragment.appendChild(createTreeNodeElement(node, 0));
        });

        container.appendChild(fragment);
    }

    function createTreeNodeElement(node, level) {
        const fragment = document.createDocumentFragment();
        const item = document.createElement('div');
        item.classList.add('tree-item');
        item.dataset.id = node.id;
        item.dataset.type = node.type;
        item.style.paddingLeft = `${level * 16}px`;

        if (projectExplorerState.selectedId === node.id) {
            item.classList.add('selected');
        }

        const icon = document.createElement('div');
        icon.classList.add('tree-icon');

        if (node.type === 'folder') {
            icon.classList.add(node.expanded ? 'expanded' : 'collapsed');
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

        if (node.children && node.children.length > 0) {
            const childrenContainer = document.createElement('div');
            childrenContainer.classList.add('tree-children');
            childrenContainer.style.display = node.expanded ? 'flex' : 'none';

            node.children.forEach(child => {
                childrenContainer.appendChild(createTreeNodeElement(child, level + 1));
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
        // 컨텍스트 메뉴
        document.querySelectorAll('.context-menu-item').forEach(item => {
            item.addEventListener('click', function() {
                const action = this.dataset.action;
                executeAction(action);
                hideContextMenu();
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
            }
        });

        clearSelection();
        render();
        updateMinimap();
        updateUI();
        setDirty(true);
        log('info', `${mindmapState.selectedNodes.size}개 노드가 삭제되었습니다.`);
    }

    function addNode() {
        const containerRect = document.querySelector('.canvas-container').getBoundingClientRect();
        const screenX = Math.random() * (containerRect.width - 200) + 100;
        const screenY = Math.random() * (containerRect.height - 200) + 100;
        const { x, y } = screenToWorld(screenX, screenY);

        createNode(`새 노드 ${mindmapState.nodeIdCounter}`, x, y);
        log('info', '새 노드가 추가되었습니다.');
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
        createConnection(parentId, childId);
        log('info', '하위 노드가 추가되었습니다.');
    }

    function addSiblingNode(siblingId) {
        const sibling = mindmapState.nodes.get(siblingId);
        if (!sibling) return;

        const parentId = sibling.parentId;
        const x = sibling.x;
        const y = sibling.y + 80;

        const newSiblingId = createNode(`형제 노드 ${mindmapState.nodeIdCounter}`, x, y, parentId);
        if (parentId) {
            createConnection(parentId, newSiblingId);
        }
        log('info', '형제 노드가 추가되었습니다.');
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
        document.querySelector('.canvas-container').appendChild(nodeElement);

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
            style: {
                backgroundColor: '#505050',
                color: '#ffffff',
                borderColor: '#666666',
                fontSize: 14
            }
        };

        mindmapState.nodes.set(nodeId, node);

        applyNodePosition(node);

        render();
        updateMinimap();
        updateUI();
        setDirty(true);

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
            setDirty(true);
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

    function createConnection(fromId, toId) {
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
        setDirty(true);
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
        ui.ctx.strokeStyle = '#666';
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
        ui.minimapCtx.fillStyle = '#2f3349';
        ui.minimapCtx.fillRect(0, 0, 200, 120);

        // 노드들을 미니맵에 그리기
        const scaleX = 200 / canvas.width;
        const scaleY = 120 / canvas.height;

        mindmapState.nodes.forEach(node => {
            const x = node.x * scaleX;
            const y = node.y * scaleY;

            ui.minimapCtx.fillStyle = node.isRoot ? '#0e7db8' : '#666';
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
            document.getElementById('prop-bgcolor').value = '#505050';
            document.getElementById('prop-color').value = '#ffffff';
            document.getElementById('prop-fontsize').value = '14';
            document.getElementById('prop-bordercolor').value = '#666666';
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
        document.querySelector('.zoom-level').textContent = `${zoomPercent}%`;
        document.getElementById('status-zoom').textContent = `줌: ${zoomPercent}%`;
    }

    // === 속성 업데이트 함수들 ===

    function updateNodeText() {
        const newText = this.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.text = newText;
                if (node.element) {
                    node.element.textContent = newText;
                }
            }
        });
        setDirty(true);
    }

    function updateNodeBackgroundColor() {
        const color = this.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.style.backgroundColor = color;
                if (node.element) {
                    node.element.style.backgroundColor = color;
                }
            }
        });
        setDirty(true);
    }

    function updateNodeColor() {
        const color = this.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.style.color = color;
                if (node.element) {
                    node.element.style.color = color;
                }
            }
        });
        setDirty(true);
    }

    function updateNodeFontSize() {
        const fontSize = parseInt(this.value);
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.style.fontSize = fontSize;
                if (node.element) {
                    node.element.style.fontSize = fontSize + 'px';
                }
            }
        });
        setDirty(true);
    }

    function updateNodeBorderColor() {
        const color = this.value;
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.style.borderColor = color;
                if (node.element) {
                    node.element.style.borderColor = color;
                }
            }
        });
        setDirty(true);
    }

    function updateNodeX() {
        const newX = parseInt(this.value);
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
        setDirty(true);
    }

    function updateNodeY() {
        const newY = parseInt(this.value);
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
        setDirty(true);
    }

    // === 문서 관리 함수들 ===

    function newDocument() {
        if (mindmapState.isDirty && !confirm('저장하지 않은 변경사항이 있습니다. 계속하시겠습니까?')) {
            return;
        }

        // 모든 노드 삭제 (루트 제외)
        document.querySelectorAll('.mind-node:not(.root)').forEach(node => node.remove());

        // 상태 초기화
        mindmapState.nodes.clear();
        mindmapState.connections.clear();
        mindmapState.selectedNodes.clear();
        mindmapState.nodeIdCounter = 2;

        // 루트 노드만 다시 생성
        createRootNode();

        render();
        updateMinimap();
        updateUI();
        setDirty(false);
        log('info', '새 문서가 생성되었습니다.');
    }

    function createRootNode() {
        const containerRect = document.querySelector('.canvas-container').getBoundingClientRect();
        const screenX = containerRect.width / 2 - 60;
        const screenY = containerRect.height / 2 - 20;
        const { x, y } = screenToWorld(screenX, screenY);

        const rootElement = document.createElement('div');
        rootElement.className = 'mind-node root';
        rootElement.id = 'node-1';
        rootElement.dataset.id = '1';
        rootElement.textContent = '중심 아이디어';

        document.querySelector('.canvas-container').appendChild(rootElement);

        rootElement.addEventListener('mousedown', onNodeMouseDown);
        rootElement.addEventListener('dblclick', onNodeDoubleClick);

        const rootNode = {
            id: '1',
            text: '중심 아이디어',
            x: x,
            y: y,
            parentId: null,
            element: rootElement,
            isRoot: true,
            style: {
                backgroundColor: '#0e7db8',
                color: '#ffffff',
                borderColor: '#1890d9',
                fontSize: 14
            }
        };

        mindmapState.nodes.set('1', rootNode);
        applyNodePosition(rootNode);
    }

    function saveDocument() {
        // 실제 구현에서는 서버로 데이터 전송
        const data = exportToJSON();
        localStorage.setItem('mindmap-autosave', data);
        setDirty(false);
        log('info', '문서가 저장되었습니다.');
    }

    function openDocument() {
        // 실제 구현에서는 파일 선택 다이얼로그
        const data = localStorage.getItem('mindmap-autosave');
        if (data) {
            importFromJSON(data);
            log('info', '문서가 열렸습니다.');
        } else {
            log('warn', '저장된 문서가 없습니다.');
        }
    }

    function exportToJSON() {
        const data = {
            nodes: Array.from(mindmapState.nodes.values()).map(node => ({
                id: node.id,
                text: node.text,
                x: node.x,
                y: node.y,
                parentId: node.parentId,
                isRoot: node.isRoot,
                style: node.style
            })),
            connections: Array.from(mindmapState.connections.values())
        };
        return JSON.stringify(data, null, 2);
    }

    function importFromJSON(jsonData) {
        try {
            const data = JSON.parse(jsonData);

            // 기존 노드 삭제
            document.querySelectorAll('.mind-node').forEach(node => node.remove());
            mindmapState.nodes.clear();
            mindmapState.connections.clear();
            mindmapState.selectedNodes.clear();

            // 노드 복원
            data.nodes.forEach(nodeData => {
                const nodeElement = document.createElement('div');
                nodeElement.className = `mind-node ${nodeData.isRoot ? 'root' : ''}`;
                nodeElement.id = `node-${nodeData.id}`;
                nodeElement.dataset.id = nodeData.id;
                if (nodeData.parentId) {
                    nodeElement.dataset.parent = nodeData.parentId;
                }
                nodeElement.textContent = nodeData.text;

                // 스타일 적용
                if (nodeData.style) {
                    nodeElement.style.backgroundColor = nodeData.style.backgroundColor;
                    nodeElement.style.color = nodeData.style.color;
                    nodeElement.style.borderColor = nodeData.style.borderColor;
                    nodeElement.style.fontSize = nodeData.style.fontSize + 'px';
                }

                document.querySelector('.canvas-container').appendChild(nodeElement);

                nodeElement.addEventListener('mousedown', onNodeMouseDown);
                nodeElement.addEventListener('dblclick', onNodeDoubleClick);

                mindmapState.nodes.set(nodeData.id, {
                    ...nodeData,
                    element: nodeElement
                });
            });

            applyAllNodePositions();

            // 연결 복원
            data.connections.forEach(connData => {
                mindmapState.connections.set(connData.id, connData);
            });

            // 노드 ID 카운터 업데이트
            const maxId = Math.max(...data.nodes.map(n => parseInt(n.id)));
            mindmapState.nodeIdCounter = maxId + 1;

            render();
            updateMinimap();
            updateUI();
            setDirty(false);

        } catch (error) {
            log('error', '문서 불러오기 실패: ' + error.message);
        }
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
            mindmapState.currentMode = 'connect';
            canvas.style.cursor = 'crosshair';
            document.querySelector('[data-action="connect"]').classList.add('active');
            updateStatus('연결 모드: 첫 번째 노드를 선택하세요');
            log('info', '연결 모드가 활성화되었습니다.');
        }
    }

    function clearConnectMode() {
        mindmapState.currentMode = 'select';
        ui.connectFrom = null;
        canvas.style.cursor = 'crosshair';
        document.querySelector('[data-action="connect"]').classList.remove('active');

        // 연결 대기 중인 노드 스타일 복원
        document.querySelectorAll('.mind-node').forEach(node => {
            if (node.style.borderColor === 'rgb(255, 107, 107)') {
                const nodeData = mindmapState.nodes.get(node.dataset.id);
                if (nodeData) {
                    node.style.borderColor = nodeData.style.borderColor;
                }
            }
        });

        updateStatus();
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
                node.style = {...clipNode.style};
                node.isRoot = false; // 붙여넣은 노드는 루트가 될 수 없음

                // 스타일 적용
                if (node.element) {
                    node.element.style.backgroundColor = node.style.backgroundColor;
                    node.element.style.color = node.style.color;
                    node.element.style.borderColor = node.style.borderColor;
                    node.element.style.fontSize = node.style.fontSize + 'px';
                }

                selectNode(nodeId);
            }
        });

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
    }

    function showContextMenu(x, y) {
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
        // 실제로는 명령 패턴을 사용하여 구현
        log('info', '실행취소가 실행되었습니다.');
    }

    function redo() {
        // 실제로는 명령 패턴을 사용하여 구현
        log('info', '다시실행이 실행되었습니다.');
    }

    function toggleGrid() {
        if (canvas.style.backgroundImage.includes('radial-gradient')) {
            canvas.style.backgroundImage = 'none';
            log('info', '격자가 숨겨졌습니다.');
        } else {
            canvas.style.backgroundImage = 'radial-gradient(circle, #4a4a4a 1px, transparent 1px)';
            canvas.style.backgroundSize = '20px 20px';
            log('info', '격자가 표시되었습니다.');
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

        const tabsContainer = document.querySelector('.editor-tabs');
        if (!tabsContainer) return;

        let tab = tabsContainer.querySelector(`.editor-tab[data-file="${filename}"]`);
        if (!tab) {
            tab = document.createElement('div');
            tab.classList.add('editor-tab');
            tab.dataset.file = filename;
            tab.innerHTML = `🗺️ ${filename} <span class="close-btn" data-action="closetab">×</span>`;
            tabsContainer.appendChild(tab);
        }

        activateTab(filename);
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

        if (isActive && tabsContainer) {
            const remaining = tabsContainer.querySelectorAll('.editor-tab');
            if (remaining.length > 0) {
                const fallback = remaining[remaining.length - 1];
                fallback.classList.add('active');
                if (fallback.dataset.file) {
                    highlightProjectFile(fallback.dataset.file);
                    updateStatus(`파일 열림: ${fallback.dataset.file}`);
                }
            } else {
                projectExplorerState.selectedId = null;
                renderProjectTree();
                updateStatus('파일 닫힘');
            }
        } else if (closingFile) {
            const activeTab = document.querySelector('.editor-tab.active');
            if (activeTab && activeTab.dataset.file) {
                highlightProjectFile(activeTab.dataset.file);
            }
        }
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
        // 속성 패널에 포커스
        document.querySelector('.right-panel').scrollIntoView();
        log('info', '속성 패널을 표시했습니다.');
    }

    // === 전역 이벤트 ===

    // 전역 클릭으로 컨텍스트 메뉴와 드롭다운 닫기
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.context-menu')) {
            hideContextMenu();
        }
    });

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

    let selectionBox = null;
    let selectionStart = null;
    let isSelecting = false;


    function onCanvasMouseDown(e) {
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;


    // Ctrl 키 누른 상태에서 왼쪽 버튼 드래그 → 멀티 선택 박스
    if (e.button === 0 && e.ctrlKey) {
    isSelecting = true;
    selectionStart = { x, y };


    selectionBox = document.createElement('div');
    selectionBox.className = 'selection-box';
    selectionBox.style.left = x + 'px';
    selectionBox.style.top = y + 'px';
    selectionBox.style.width = '0px';
    selectionBox.style.height = '0px';
    canvas.parentElement.appendChild(selectionBox);


    document.addEventListener('mousemove', onSelectionMouseMove);
    document.addEventListener('mouseup', onSelectionMouseUp);
    return;
    }


    // === 기존 Pan/노드 선택 로직 ===
    if (mindmapState.currentMode === 'pan' || e.button === 1) {
    ui.isDragging = true;
    canvas.style.cursor = 'grabbing';
    }
    }


    function onSelectionMouseMove(e) {
    if (!isSelecting || !selectionStart) return;


    const rect = canvas.getBoundingClientRect();
    const currentX = e.clientX - rect.left;
    const currentY = e.clientY - rect.top;


    const x = Math.min(selectionStart.x, currentX);
    const y = Math.min(selectionStart.y, currentY);
    const w = Math.abs(selectionStart.x - currentX);
    const h = Math.abs(selectionStart.y - currentY);


    selectionBox.style.left = x + 'px';
    selectionBox.style.top = y + 'px';
    selectionBox.style.width = w + 'px';
    selectionBox.style.height = h + 'px';
    }


    function onSelectionMouseUp(e) {
    if (!isSelecting) return;


    const boxRect = selectionBox.getBoundingClientRect();
    document.querySelectorAll('.mind-node').forEach(nodeEl => {
    const nodeRect = nodeEl.getBoundingClientRect();
    if (!(nodeRect.right < boxRect.left || nodeRect.left > boxRect.right ||
    nodeRect.bottom < boxRect.top || nodeRect.top > boxRect.bottom)) {
    const nodeId = nodeEl.dataset.id;
    selectNode(nodeId);
    }
    });


    selectionBox.remove();
    selectionBox = null;
    selectionStart = null;
    isSelecting = false;


    document.removeEventListener('mousemove', onSelectionMouseMove);
    document.removeEventListener('mouseup', onSelectionMouseUp);
    }
})();