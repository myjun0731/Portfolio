
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

    const collaborationState = {
        localUser: null,
        presence: new Map(),
        socket: null,
        connectionState: 'disconnected',
        reconnectAttempts: 0,
        maxReconnectAttempts: 5,
        pendingMessages: [],
        pingInterval: null,
        latency: null,
        documentVersion: 0,
        lastUpdate: null,
        suppressBroadcast: false,
        offlineDemoTimer: null,
        activityHistory: [],
        reconnectTimer: null
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
        lastMousePos: { x: 0, y: 0 },
        dragInitialPositions: new Map(),
        dragHasMoved: false
    };

    const selectionState = {
        isSelecting: false,
        start: null,
        boxElement: null,
        additive: false
    };

    // DOM 요소 참조
    const canvas = document.getElementById('mindmap-canvas');
    const minimapCanvas = document.getElementById('minimap-canvas');
    const consoleOutput = document.getElementById('console');
    const contextMenu = document.getElementById('context-menu');
    const collaborationIndicator = document.getElementById('collaboration-indicator');
    const collaborationStatusText = document.getElementById('collaboration-status-text');
    const collaborationLatency = document.getElementById('collaboration-latency');
    const collaborationAvatars = document.getElementById('collaboration-avatars');
    const collaborationActivityContainer = document.getElementById('collaboration-activity');
    const collaborationVersionLabel = document.getElementById('collaboration-version');
    const collaborationUpdatedAtLabel = document.getElementById('collaboration-updated-at');
    const statusCollaboration = document.getElementById('status-collaboration');
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

    // === 협업 상태 관리 ===
    function initCollaboration() {
        if (!collaborationState.localUser) {
            collaborationState.localUser = createLocalUserProfile();
        }
        registerPresence(collaborationState.localUser);
        updateCollaborationUI('실시간 협업 준비 완료');
        setTimeout(() => {
            connectCollaboration();
        }, 300);
    }

    function createLocalUserProfile() {
        let storedName = null;
        try {
            storedName = localStorage.getItem('collamind-display-name');
        } catch (error) {
            storedName = null;
        }
        const fallbackNames = ['에디터', '메이커', '플래너', '크리에이터'];
        if (!storedName || !storedName.trim()) {
            storedName = `${fallbackNames[Math.floor(Math.random() * fallbackNames.length)]} ${Math.floor(Math.random() * 900 + 100)}`;
        }
        const palette = ['#4caf50', '#ffb300', '#8e24aa', '#03a9f4', '#f44336', '#009688'];
        const color = palette[Math.floor(Math.random() * palette.length)];
        return {
            id: `local-${Math.random().toString(36).slice(2, 8)}`,
            name: storedName.trim(),
            color,
            role: 'Editor',
            isLocal: true
        };
    }

    function getConnectionLabel() {
        switch (collaborationState.connectionState) {
            case 'connected':
                return '실시간 동기화됨';
            case 'connecting':
                return '연결 시도 중...';
            case 'demo':
                return '오프라인 데모 모드';
            default:
                return '오프라인';
        }
    }

    function updateCollaborationUI(statusMessage = null) {
        if (collaborationIndicator) {
            collaborationIndicator.dataset.state = collaborationState.connectionState;
        }
        if (collaborationStatusText) {
            collaborationStatusText.textContent = statusMessage || getConnectionLabel();
        }
        if (collaborationLatency) {
            collaborationLatency.textContent = collaborationState.latency != null
                ? `지연: ${Math.round(collaborationState.latency)}ms`
                : (collaborationState.connectionState === 'connected' ? '지연 측정 중' : '연결 대기 중');
        }
        updatePresenceList();
        updateCollaborationStatusBar();
    }

    function registerPresence(user) {
        if (!user || !user.id) return;
        collaborationState.presence.set(user.id, {
            ...collaborationState.presence.get(user.id),
            ...user,
            lastActive: Date.now()
        });
        updatePresenceList();
    }

    function updatePresenceList() {
        if (!collaborationAvatars) return;
        collaborationAvatars.innerHTML = '';
        const users = Array.from(collaborationState.presence.values());
        users.sort((a, b) => {
            if ((a.isLocal ? 0 : 1) === (b.isLocal ? 0 : 1)) {
                return (a.name || '').localeCompare(b.name || '', 'ko');
            }
            return a.isLocal ? -1 : 1;
        });
        const fragment = document.createDocumentFragment();
        users.forEach(user => fragment.appendChild(createPresenceAvatar(user)));
        collaborationAvatars.appendChild(fragment);
    }

    function createPresenceAvatar(user) {
        const avatar = document.createElement('div');
        avatar.className = 'presence-avatar';
        avatar.dataset.local = user.isLocal ? 'true' : 'false';
        avatar.style.background = user.color || '#5a6287';
        avatar.textContent = (user.name || '?').trim().charAt(0).toUpperCase();
        const tooltip = document.createElement('div');
        tooltip.className = 'avatar-tooltip';
        tooltip.textContent = `${user.name || '참여자'}${user.role ? ` · ${user.role}` : ''}`;
        avatar.appendChild(tooltip);
        return avatar;
    }

    function updateCollaborationStatusBar() {
        if (statusCollaboration) {
            statusCollaboration.textContent = `협업: ${getConnectionLabel()}`;
            statusCollaboration.dataset.state = collaborationState.connectionState;
        }
        if (collaborationVersionLabel) {
            collaborationVersionLabel.textContent = `v${collaborationState.documentVersion}`;
        }
        if (collaborationUpdatedAtLabel) {
            collaborationUpdatedAtLabel.textContent = collaborationState.lastUpdate
                ? new Date(collaborationState.lastUpdate).toLocaleTimeString()
                : '-';
        }
    }

    function disconnectCollaborationSocket() {
        if (collaborationState.socket) {
            try {
                collaborationState.socket.close();
            } catch (error) {
                console.warn('collaboration socket close error', error);
            }
            collaborationState.socket = null;
        }
        stopPing();
    }

    function buildCollaborationUrl() {
        const protocol = (location.protocol === 'https:') ? 'wss://' : 'ws://';
        const host = location.host || 'localhost:8080';
        return `${protocol}${host}/collaboration`;
    }

    function connectCollaboration() {
        stopOfflineDemoMode();
        if (typeof WebSocket === 'undefined') {
            startOfflineDemoMode('현재 환경에서는 WebSocket을 사용할 수 없습니다.');
            return;
        }
        disconnectCollaborationSocket();
        if (collaborationState.reconnectTimer) {
            clearTimeout(collaborationState.reconnectTimer);
            collaborationState.reconnectTimer = null;
        }
        collaborationState.connectionState = 'connecting';
        collaborationState.latency = null;
        updateCollaborationUI('실시간 서버 연결 중...');
        let socket;
        try {
            socket = new WebSocket(buildCollaborationUrl());
        } catch (error) {
            onSocketError(error);
            scheduleReconnect();
            return;
        }
        collaborationState.socket = socket;
        socket.addEventListener('open', onSocketOpen);
        socket.addEventListener('message', onSocketMessage);
        socket.addEventListener('close', onSocketClose);
        socket.addEventListener('error', onSocketError);
    }

    function onSocketOpen() {
        collaborationState.connectionState = 'connected';
        collaborationState.reconnectAttempts = 0;
        updateCollaborationUI('실시간 서버에 연결되었습니다');
        recordActivity('system', '실시간 협업 서버와 연결되었습니다.', { level: 'info' });
        sendCollaborationMessage({
            type: 'presence',
            payload: { user: collaborationState.localUser, status: 'online' }
        });
        flushPendingMessages();
        startPing();
    }

    function onSocketMessage(event) {
        let message;
        try {
            message = JSON.parse(event.data);
        } catch (error) {
            console.warn('Invalid collaboration payload', error);
            return;
        }
        if (!message || !message.type) return;
        switch (message.type) {
            case 'pong':
                handlePong(message);
                break;
            case 'presence':
                handlePresencePayload(message.payload);
                break;
            case 'operation':
                handleCollaborationOperation(message);
                break;
            case 'activity':
                if (message.payload) {
                    recordActivity('remote', message.payload.message || '활동 업데이트', { actor: message.actor });
                }
                break;
            default:
                break;
        }
    }

    function handlePresencePayload(payload) {
        if (!payload) return;
        if (Array.isArray(payload.users)) {
            payload.users.forEach(registerPresence);
        }
        if (payload.user) {
            registerPresence(payload.user);
        }
    }

    function handleCollaborationOperation(message) {
        applyRemoteOperation(message);
    }

    function startPing() {
        stopPing();
        collaborationState.pingInterval = setInterval(() => {
            sendCollaborationMessage({ type: 'ping', timestamp: Date.now() });
        }, 15000);
    }

    function stopPing() {
        if (collaborationState.pingInterval) {
            clearInterval(collaborationState.pingInterval);
            collaborationState.pingInterval = null;
        }
    }

    function handlePong(message) {
        if (typeof message.timestamp === 'number') {
            collaborationState.latency = Date.now() - message.timestamp;
            updateCollaborationUI();
        }
    }

    function onSocketClose() {
        if (collaborationState.connectionState === 'demo') return;
        collaborationState.connectionState = 'disconnected';
        collaborationState.latency = null;
        updateCollaborationUI('연결이 종료되었습니다. 재시도합니다.');
        scheduleReconnect();
    }

    function onSocketError(error) {
        if (collaborationState.connectionState !== 'demo') {
            collaborationState.connectionState = 'disconnected';
            collaborationState.latency = null;
            recordActivity('alert', '실시간 서버와의 통신에 문제가 발생했습니다.', { error: error?.message });
            updateCollaborationUI('연결 오류');
            scheduleReconnect();
        }
    }

    function scheduleReconnect() {
        if (collaborationState.connectionState === 'demo') return;
        const attempt = ++collaborationState.reconnectAttempts;
        if (attempt > collaborationState.maxReconnectAttempts) {
            startOfflineDemoMode('서버 연결이 원활하지 않아 데모 모드로 전환합니다.');
            return;
        }
        const delay = Math.min(1000 * attempt, 5000);
        if (collaborationState.reconnectTimer) {
            clearTimeout(collaborationState.reconnectTimer);
        }
        collaborationState.reconnectTimer = setTimeout(connectCollaboration, delay);
    }

    function flushPendingMessages() {
        if (!collaborationState.socket || collaborationState.socket.readyState !== WebSocket.OPEN) return;
        while (collaborationState.pendingMessages.length > 0) {
            const payload = collaborationState.pendingMessages.shift();
            collaborationState.socket.send(JSON.stringify(payload));
        }
    }

    function sendCollaborationMessage(message) {
        if (!message) return;
        if (collaborationState.socket && collaborationState.socket.readyState === WebSocket.OPEN) {
            collaborationState.socket.send(JSON.stringify(message));
        } else {
            collaborationState.pendingMessages.push(message);
        }
    }

    function withSuppressedBroadcast(callback) {
        collaborationState.suppressBroadcast = true;
        try {
            callback();
        } finally {
            collaborationState.suppressBroadcast = false;
        }
    }

    function applyRemoteOperation(message) {
        if (!message || !message.payload) return;
        withSuppressedBroadcast(() => {
            switch (message.kind) {
                case 'node-create':
                    if (message.payload.node && !mindmapState.nodes.has(message.payload.node.id)) {
                        const nodeData = message.payload.node;
                        createNode(nodeData.text, nodeData.x, nodeData.y, nodeData.parentId || null, {
                            id: nodeData.id,
                            style: nodeData.style,
                            isRoot: nodeData.isRoot,
                            skipBroadcast: true
                        });
                    }
                    break;
                case 'node-delete':
                    if (Array.isArray(message.payload.nodeIds)) {
                        message.payload.nodeIds.forEach(id => {
                            const node = mindmapState.nodes.get(id);
                            if (node && node.element) {
                                node.element.remove();
                            }
                            mindmapState.nodes.delete(id);
                            mindmapState.selectedNodes.delete(id);
                        });
                        mindmapState.connections.forEach((conn, connId) => {
                            if (message.payload.nodeIds.includes(conn.from) || message.payload.nodeIds.includes(conn.to)) {
                                mindmapState.connections.delete(connId);
                            }
                        });
                        render();
                        updateMinimap();
                    }
                    break;
                case 'node-move':
                    if (Array.isArray(message.payload.nodes)) {
                        message.payload.nodes.forEach(nodeInfo => {
                            const node = mindmapState.nodes.get(nodeInfo.id);
                            if (!node) return;
                            node.x = nodeInfo.x;
                            node.y = nodeInfo.y;
                            applyNodePosition(node);
                        });
                        render();
                        updateMinimap();
                    }
                    break;
                case 'node-style':
                case 'node-update':
                    if (Array.isArray(message.payload.nodeIds) && message.payload.changes) {
                        message.payload.nodeIds.forEach(nodeId => {
                            const node = mindmapState.nodes.get(nodeId);
                            if (!node) return;
                            const changes = message.payload.changes;
                            if (changes.text !== undefined) {
                                node.text = changes.text;
                                if (node.element) node.element.textContent = changes.text;
                            }
                            if (changes.backgroundColor) {
                                node.style.backgroundColor = changes.backgroundColor;
                                if (node.element) node.element.style.backgroundColor = changes.backgroundColor;
                            }
                            if (changes.color) {
                                node.style.color = changes.color;
                                if (node.element) node.element.style.color = changes.color;
                            }
                            if (changes.fontSize) {
                                node.style.fontSize = changes.fontSize;
                                if (node.element) node.element.style.fontSize = `${changes.fontSize}px`;
                            }
                            if (changes.borderColor) {
                                node.style.borderColor = changes.borderColor;
                                if (node.element) node.element.style.borderColor = changes.borderColor;
                            }
                            if (changes.x !== undefined) {
                                node.x = changes.x;
                                applyNodePosition(node);
                            }
                            if (changes.y !== undefined) {
                                node.y = changes.y;
                                applyNodePosition(node);
                            }
                        });
                        render();
                        updateMinimap();
                    }
                    break;
                case 'connection-create':
                    if (message.payload && message.payload.id) {
                        if (!mindmapState.connections.has(message.payload.id)) {
                            mindmapState.connections.set(message.payload.id, {
                                id: message.payload.id,
                                from: message.payload.from,
                                to: message.payload.to
                            });
                            render();
                            updateMinimap();
                        }
                    }
                    break;
                case 'connection-delete':
                    if (Array.isArray(message.payload.ids)) {
                        message.payload.ids.forEach(id => mindmapState.connections.delete(id));
                        render();
                        updateMinimap();
                    }
                    break;
                default:
                    break;
            }
        });
        updateUI();
        if (message.actor) {
            registerPresence(message.actor);
        }
        const description = formatOperationMessage(message.kind, message.payload);
        recordActivity('remote', description, { version: message.version, actor: message.actor });
        updateCollaborationMetadata(message);
    }

    function formatOperationMessage(kind, payload) {
        switch (kind) {
            case 'node-create':
                return `새 노드 생성: ${payload?.node?.text || '제목 없음'}`;
            case 'node-delete':
                return `${payload?.nodeIds?.length || 0}개 노드 삭제`;
            case 'node-move':
                return `${payload?.nodes?.length || 0}개 노드 위치 이동`;
            case 'node-style':
            case 'node-update':
                return '노드 속성 업데이트';
            case 'connection-create':
                return '노드 연결 추가';
            case 'connection-delete':
                return '노드 연결 삭제';
            default:
                return '변경 사항 동기화';
        }
    }

    function updateCollaborationMetadata(message) {
        if (message && message.version) {
            collaborationState.documentVersion = Math.max(collaborationState.documentVersion, message.version);
        } else {
            collaborationState.documentVersion += 1;
        }
        if (message && message.timestamp) {
            collaborationState.lastUpdate = message.timestamp;
        } else {
            collaborationState.lastUpdate = Date.now();
        }
        updateCollaborationStatusBar();
    }

    function recordActivity(source, message, meta = {}) {
        if (!message || !collaborationActivityContainer) return;
        const item = document.createElement('div');
        item.className = `activity-item activity-${getActivitySourceClass(source)}`;
        const headline = document.createElement('div');
        headline.className = 'activity-headline';
        const title = document.createElement('span');
        title.textContent = message;
        const actor = document.createElement('span');
        actor.textContent = meta.actor?.name || (source === 'local' ? collaborationState.localUser?.name || '나' : '시스템');
        headline.appendChild(title);
        headline.appendChild(actor);
        const metaRow = document.createElement('div');
        metaRow.className = 'activity-meta';
        const versionText = meta.version ? `v${meta.version}` : '';
        metaRow.innerHTML = `<span>${new Date().toLocaleTimeString()}</span><span>${versionText}</span>`;
        item.appendChild(headline);
        item.appendChild(metaRow);
        collaborationActivityContainer.prepend(item);
        collaborationState.activityHistory.unshift({ source, message, timestamp: Date.now() });
        pruneActivityLog();
    }

    function getActivitySourceClass(source) {
        switch (source) {
            case 'local':
                return 'local';
            case 'remote':
                return 'remote';
            case 'alert':
                return 'alert';
            default:
                return 'system';
        }
    }

    function pruneActivityLog() {
        const maxEntries = 25;
        while (collaborationActivityContainer.childNodes.length > maxEntries) {
            collaborationActivityContainer.removeChild(collaborationActivityContainer.lastChild);
        }
        if (collaborationState.activityHistory.length > maxEntries) {
            collaborationState.activityHistory.length = maxEntries;
        }
    }

    function startOfflineDemoMode(reason = '네트워크 연결을 사용할 수 없습니다.') {
        disconnectCollaborationSocket();
        collaborationState.connectionState = 'demo';
        collaborationState.latency = null;
        updateCollaborationUI('데모 모드 활성화');
        recordActivity('system', reason, { level: 'info' });
        if (collaborationState.offlineDemoTimer) {
            clearInterval(collaborationState.offlineDemoTimer);
        }
        const demoUsers = [
            { id: 'demo-ux', name: 'UX Buddy', color: '#ff8a65', role: 'Designer', isLocal: false },
            { id: 'demo-ai', name: 'InsightBot', color: '#7e57c2', role: 'AI Assistant', isLocal: false }
        ];
        demoUsers.forEach(registerPresence);
        let scenarioIndex = 0;
        function runDemoScript() {
            const actor = demoUsers[scenarioIndex % demoUsers.length];
            scenarioIndex++;
            const operations = [
                () => applyRemoteOperation({ type: 'operation', kind: 'node-style', payload: { nodeIds: ['2'], changes: { backgroundColor: '#7e57c2' } }, actor, version: collaborationState.documentVersion + 1, timestamp: Date.now() }),
                () => applyRemoteOperation({ type: 'operation', kind: 'node-update', payload: { nodeIds: ['3'], changes: { text: '원격 제안 아이디어' } }, actor, version: collaborationState.documentVersion + 1, timestamp: Date.now() }),
                () => applyRemoteOperation({ type: 'operation', kind: 'node-create', payload: { node: { id: `demo-${Date.now()}`, text: '데모 노드', x: 520 + Math.random() * 120, y: 280 + Math.random() * 120, parentId: '1', isRoot: false, style: { backgroundColor: '#26a69a', color: '#ffffff', borderColor: '#1f8f81', fontSize: 14 } } }, actor, version: collaborationState.documentVersion + 1, timestamp: Date.now() })
            ];
            const operation = operations[Math.floor(Math.random() * operations.length)];
            operation();
        }
        collaborationState.offlineDemoTimer = setInterval(runDemoScript, 15000);
        runDemoScript();
    }

    function stopOfflineDemoMode() {
        if (collaborationState.offlineDemoTimer) {
            clearInterval(collaborationState.offlineDemoTimer);
            collaborationState.offlineDemoTimer = null;
        }
        [...collaborationState.presence.keys()].forEach(id => {
            if (id.startsWith('demo-')) {
                collaborationState.presence.delete(id);
            }
        });
        updatePresenceList();
    }

    function toggleOfflineMode() {
        if (collaborationState.connectionState === 'demo') {
            stopOfflineDemoMode();
            collaborationState.connectionState = 'disconnected';
            updateCollaborationUI('오프라인 모드가 종료되었습니다.');
            connectCollaboration();
        } else {
            startOfflineDemoMode('사용자 요청으로 데모 모드를 시작합니다.');
        }
    }

    function requestResync() {
        log('info', '서버에 최신 문서 동기화를 요청했습니다.');
        sendCollaborationMessage({ type: 'resync-request', timestamp: Date.now() });
    }

    function shareCollaborationLink() {
        const sessionId = collaborationState.localUser?.id || 'collamind-session';
        let origin = '';
        try {
            origin = window.location.origin || '';
        } catch (error) {
            origin = '';
        }
        if (!origin || origin === 'null') {
            origin = '';
        }
        const basePath = window.location.pathname || '';
        const url = `${origin}${basePath}#session=${sessionId}`;
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(url).then(() => {
                log('info', '협업 링크가 클립보드에 복사되었습니다.');
            }).catch(() => {
                log('warn', `클립보드 접근이 제한되어 링크를 복사하지 못했습니다. 링크: ${url}`);
            });
        } else {
            log('info', `협업 링크: ${url}`);
        }
    }

    function broadcastOperation(kind, payload) {
        if (collaborationState.suppressBroadcast) return;
        const version = ++collaborationState.documentVersion;
        const message = {
            type: 'operation',
            kind,
            payload,
            version,
            timestamp: Date.now(),
            actor: collaborationState.localUser
        };
        sendCollaborationMessage(message);
        const description = formatOperationMessage(kind, payload);
        recordActivity('local', description, { version });
        collaborationState.lastUpdate = message.timestamp;
        updateCollaborationMetadata(message);
    }

    function serializeNodeForCollaboration(node) {
        if (!node) return null;
        return {
            id: node.id,
            text: node.text,
            x: node.x,
            y: node.y,
            parentId: node.parentId,
            isRoot: node.isRoot,
            style: { ...node.style }
        };
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

        initCollaboration();

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

    function startSelection(pointer, additive) {
        selectionState.isSelecting = true;
        selectionState.start = pointer;
        selectionState.additive = additive;
        if (!additive) {
            clearSelection();
        }

        const box = document.createElement('div');
        box.className = 'selection-box';
        box.style.left = `${pointer.x}px`;
        box.style.top = `${pointer.y}px`;
        box.style.width = '0px';
        box.style.height = '0px';
        selectionState.boxElement = box;
        canvas.parentElement.appendChild(box);

        document.addEventListener('mousemove', onSelectionMouseMove);
        document.addEventListener('mouseup', onSelectionMouseUp);
    }

    function updateSelectionBoxVisual(pointer) {
        if (!selectionState.boxElement || !selectionState.start) return;
        const x = Math.min(selectionState.start.x, pointer.x);
        const y = Math.min(selectionState.start.y, pointer.y);
        const width = Math.abs(selectionState.start.x - pointer.x);
        const height = Math.abs(selectionState.start.y - pointer.y);
        Object.assign(selectionState.boxElement.style, {
            left: `${x}px`,
            top: `${y}px`,
            width: `${width}px`,
            height: `${height}px`
        });
    }

    function finishSelection() {
        if (selectionState.boxElement) {
            selectionState.boxElement.remove();
        }
        selectionState.isSelecting = false;
        selectionState.start = null;
        selectionState.boxElement = null;
        selectionState.additive = false;
        document.removeEventListener('mousemove', onSelectionMouseMove);
        document.removeEventListener('mouseup', onSelectionMouseUp);
    }

    function onSelectionMouseMove(e) {
        if (!selectionState.isSelecting) return;
        const rect = canvas.getBoundingClientRect();
        updateSelectionBoxVisual({
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        });
    }

    function onSelectionMouseUp() {
        if (!selectionState.isSelecting) return;
        if (selectionState.boxElement) {
            const boxRect = selectionState.boxElement.getBoundingClientRect();
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
        finishSelection();
    }

    // 캔버스 마우스 다운
    function onCanvasMouseDown(e) {
        const rect = canvas.getBoundingClientRect();
        const pointer = {
            x: e.clientX - rect.left,
            y: e.clientY - rect.top
        };
        ui.lastMousePos = pointer;

        if (e.button === 0 && (e.ctrlKey || e.metaKey)) {
            startSelection(pointer, e.shiftKey);
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

        if (selectionState.isSelecting) {
            updateSelectionBoxVisual(currentPos);
            return;
        }

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
        if (!e.ctrlKey && !e.metaKey && !e.shiftKey) {
            clearSelection();
        }
        selectNode(nodeId);

        // 드래그 시작
        ui.isDragging = true;
        ui.dragStartNode = nodeId;
        ui.dragInitialPositions = new Map();
        mindmapState.selectedNodes.forEach(selectedId => {
            const selectedNode = mindmapState.nodes.get(selectedId);
            if (selectedNode) {
                ui.dragInitialPositions.set(selectedId, { x: selectedNode.x, y: selectedNode.y });
            }
        });
        ui.dragHasMoved = false;

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

            if (ui.dragHasMoved && ui.dragInitialPositions.size > 0) {
                const movedNodes = [];
                ui.dragInitialPositions.forEach((startPos, nodeId) => {
                    const node = mindmapState.nodes.get(nodeId);
                    if (node && (startPos.x !== node.x || startPos.y !== node.y)) {
                        movedNodes.push({ id: nodeId, x: node.x, y: node.y });
                    }
                });
                if (movedNodes.length > 0) {
                    broadcastOperation('node-move', { nodes: movedNodes });
                }
            }
        }

        ui.isDragging = false;
        ui.dragStartNode = null;
        ui.dragStartPos = null;
        ui.dragHasMoved = false;
        ui.dragInitialPositions.clear();
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

        // 협업 컨트롤 버튼
        document.querySelectorAll('.collab-btn').forEach(btn => {
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
            case 'share': shareCollaborationLink(); break;
            case 'resync': requestResync(); break;
            case 'toggle-offline': toggleOfflineMode(); break;
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

        const deletedNodeIds = [];
        const deletedConnectionIds = [];

        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node && !node.isRoot) { // 루트 노드는 삭제 불가
                // 연결 삭제
                mindmapState.connections.forEach((conn, connId) => {
                    if (conn.from === nodeId || conn.to === nodeId) {
                        deletedConnectionIds.push(connId);
                        mindmapState.connections.delete(connId);
                    }
                });

                // DOM에서 제거
                if (node.element) {
                    node.element.remove();
                }

                // 상태에서 제거
                mindmapState.nodes.delete(nodeId);
                deletedNodeIds.push(nodeId);
            }
        });

        clearSelection();
        render();
        updateMinimap();
        updateUI();
        setDirty(true);
        if (deletedNodeIds.length > 0) {
            log('info', `${deletedNodeIds.length}개 노드가 삭제되었습니다.`);
            broadcastOperation('node-delete', { nodeIds: deletedNodeIds, connectionIds: deletedConnectionIds });
        }
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

    function createNode(text, x, y, parentId = null, options = {}) {
        const providedId = options.id ? options.id.toString() : null;
        const nodeId = providedId || mindmapState.nodeIdCounter.toString();
        if (!providedId) {
            mindmapState.nodeIdCounter++;
        } else {
            const numericId = parseInt(nodeId, 10);
            if (!Number.isNaN(numericId)) {
                mindmapState.nodeIdCounter = Math.max(mindmapState.nodeIdCounter, numericId + 1);
            }
        }

        // DOM 요소 생성
        const nodeElement = document.createElement('div');
        nodeElement.className = 'mind-node';
        nodeElement.id = `node-${nodeId}`;
        nodeElement.dataset.id = nodeId;
        if (parentId) {
            nodeElement.dataset.parent = parentId;
        }
        nodeElement.textContent = text;

        if (options.isRoot) {
            nodeElement.classList.add('root');
        }

        // 컨테이너에 추가
        document.querySelector('.canvas-container').appendChild(nodeElement);

        // 이벤트 리스너 추가
        nodeElement.addEventListener('mousedown', onNodeMouseDown);
        nodeElement.addEventListener('dblclick', onNodeDoubleClick);

        // 상태에 추가
        const nodeStyle = {
            backgroundColor: options.style?.backgroundColor || (options.isRoot ? '#0e7db8' : '#505050'),
            color: options.style?.color || '#ffffff',
            borderColor: options.style?.borderColor || (options.isRoot ? '#1890d9' : '#666666'),
            fontSize: options.style?.fontSize || 14
        };

        Object.assign(nodeElement.style, {
            backgroundColor: nodeStyle.backgroundColor,
            color: nodeStyle.color,
            borderColor: nodeStyle.borderColor,
            fontSize: `${nodeStyle.fontSize}px`
        });

        const node = {
            id: nodeId,
            text: text,
            x: x,
            y: y,
            parentId: parentId,
            element: nodeElement,
            isRoot: Boolean(options.isRoot),
            style: nodeStyle
        };

        mindmapState.nodes.set(nodeId, node);

        applyNodePosition(node);

        render();
        updateMinimap();
        updateUI();
        setDirty(true);

        if (!options.skipBroadcast) {
            broadcastOperation('node-create', { node: serializeNodeForCollaboration(node) });
        }

        return nodeId;
    }

    function moveSelectedNodes(deltaX, deltaY) {
        if (Math.abs(deltaX) > 0.01 || Math.abs(deltaY) > 0.01) {
            ui.dragHasMoved = true;
        }
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
            broadcastOperation('node-update', { nodeIds: [nodeId], changes: { text: newText } });
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
        broadcastOperation('connection-create', { id: connectionId, from: fromId, to: toId });
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
        const updatedIds = [];
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                if (node.text !== newText) {
                    node.text = newText;
                    if (node.element) {
                        node.element.textContent = newText;
                    }
                    updatedIds.push(nodeId);
                }
            }
        });
        setDirty(true);
        if (updatedIds.length > 0) {
            broadcastOperation('node-update', { nodeIds: updatedIds, changes: { text: newText } });
        }
    }

    function updateNodeBackgroundColor() {
        const color = this.value;
        const updatedIds = [];
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                if (node.style.backgroundColor !== color) {
                    node.style.backgroundColor = color;
                    if (node.element) {
                        node.element.style.backgroundColor = color;
                    }
                    updatedIds.push(nodeId);
                }
            }
        });
        setDirty(true);
        if (updatedIds.length > 0) {
            broadcastOperation('node-style', { nodeIds: updatedIds, changes: { backgroundColor: color } });
        }
    }

    function updateNodeColor() {
        const color = this.value;
        const updatedIds = [];
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                if (node.style.color !== color) {
                    node.style.color = color;
                    if (node.element) {
                        node.element.style.color = color;
                    }
                    updatedIds.push(nodeId);
                }
            }
        });
        setDirty(true);
        if (updatedIds.length > 0) {
            broadcastOperation('node-style', { nodeIds: updatedIds, changes: { color } });
        }
    }

    function updateNodeFontSize() {
        const fontSize = parseInt(this.value);
        const updatedIds = [];
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                if (node.style.fontSize !== fontSize) {
                    node.style.fontSize = fontSize;
                    if (node.element) {
                        node.element.style.fontSize = fontSize + 'px';
                    }
                    updatedIds.push(nodeId);
                }
            }
        });
        setDirty(true);
        if (updatedIds.length > 0) {
            broadcastOperation('node-style', { nodeIds: updatedIds, changes: { fontSize } });
        }
    }

    function updateNodeBorderColor() {
        const color = this.value;
        const updatedIds = [];
        mindmapState.selectedNodes.forEach(nodeId => {
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                if (node.style.borderColor !== color) {
                    node.style.borderColor = color;
                    if (node.element) {
                        node.element.style.borderColor = color;
                    }
                    updatedIds.push(nodeId);
                }
            }
        });
        setDirty(true);
        if (updatedIds.length > 0) {
            broadcastOperation('node-style', { nodeIds: updatedIds, changes: { borderColor: color } });
        }
    }

    function updateNodeX() {
        const newX = parseInt(this.value);
        let targetId = null;
        if (mindmapState.selectedNodes.size === 1) {
            const nodeId = [...mindmapState.selectedNodes][0];
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.x = newX;
                applyNodePosition(node);
                render();
                updateMinimap();
                targetId = nodeId;
            }
        }
        setDirty(true);
        if (targetId) {
            broadcastOperation('node-update', { nodeIds: [targetId], changes: { x: newX } });
        }
    }

    function updateNodeY() {
        const newY = parseInt(this.value);
        let targetId = null;
        if (mindmapState.selectedNodes.size === 1) {
            const nodeId = [...mindmapState.selectedNodes][0];
            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.y = newY;
                applyNodePosition(node);
                render();
                updateMinimap();
                targetId = nodeId;
            }
        }
        setDirty(true);
        if (targetId) {
            broadcastOperation('node-update', { nodeIds: [targetId], changes: { y: newY } });
        }
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
            const nodeId = createNode(clipNode.text, x, y, null, { style: clipNode.style });

            const node = mindmapState.nodes.get(nodeId);
            if (node) {
                node.isRoot = false; // 붙여넣은 노드는 루트가 될 수 없음

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
        if (level !== 'debug') {
            const source = level === 'warn' || level === 'error' ? 'alert' : 'system';
            recordActivity(source, message, { level });
        }
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

})();
