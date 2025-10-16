<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>CollaMind – 실시간 협업 마인드맵</title>

<link rel="stylesheet" href="mindmap.css">

</head>
<body>
	<!-- 메뉴바 -->
	<div class="menu-bar">
		<div class="menu-item" data-menu="file">
			File
			<div class="dropdown-menu">
				<div class="dropdown-item" data-action="new">
					<span>새 마인드맵</span><span>Ctrl+N</span>
				</div>
				<div class="dropdown-item" data-action="open">
					<span>열기</span><span>Ctrl+O</span>
				</div>
				<div class="dropdown-item" data-action="save">
					<span>저장</span><span>Ctrl+S</span>
				</div>
				<div class="dropdown-item" data-action="saveas">
					<span>다른 이름으로 저장</span><span>Ctrl+Shift+S</span>
				</div>
				<div class="dropdown-separator"></div>
				<div class="dropdown-item" data-action="export">
					<span>내보내기</span>
				</div>
				<div class="dropdown-item" data-action="print">
					<span>인쇄</span><span>Ctrl+P</span>
				</div>
			</div>
		</div>
		<div class="menu-item" data-menu="edit">
			Edit
			<div class="dropdown-menu">
				<div class="dropdown-item" data-action="undo">
					<span>실행취소</span><span>Ctrl+Z</span>
				</div>
				<div class="dropdown-item" data-action="redo">
					<span>다시실행</span><span>Ctrl+Y</span>
				</div>
				<div class="dropdown-separator"></div>
				<div class="dropdown-item" data-action="cut">
					<span>잘라내기</span><span>Ctrl+X</span>
				</div>
				<div class="dropdown-item" data-action="copy">
					<span>복사</span><span>Ctrl+C</span>
				</div>
				<div class="dropdown-item" data-action="paste">
					<span>붙여넣기</span><span>Ctrl+V</span>
				</div>
				<div class="dropdown-item" data-action="delete">
					<span>삭제</span><span>Del</span>
				</div>
				<div class="dropdown-separator"></div>
				<div class="dropdown-item" data-action="selectall">
					<span>모두 선택</span><span>Ctrl+A</span>
				</div>
			</div>
		</div>
		<div class="menu-item" data-menu="view">
			View
			<div class="dropdown-menu">
				<div class="dropdown-item" data-action="zoomin">
					<span>확대</span><span>Ctrl++</span>
				</div>
				<div class="dropdown-item" data-action="zoomout">
					<span>축소</span><span>Ctrl+-</span>
				</div>
				<div class="dropdown-item" data-action="zoomfit">
					<span>전체보기</span><span>Ctrl+0</span>
				</div>
				<div class="dropdown-separator"></div>
				<div class="dropdown-item" data-action="grid">
					<span>격자 표시</span>
				</div>
				<div class="dropdown-item" data-action="minimap">
					<span>미니맵</span>
				</div>
			</div>
		</div>
		<div class="menu-item" data-menu="insert">
			Insert
			<div class="dropdown-menu">
				<div class="dropdown-item" data-action="addnode">
					<span>노드 추가</span><span>Insert</span>
				</div>
				<div class="dropdown-item" data-action="addchild">
					<span>하위 노드</span><span>Tab</span>
				</div>
				<div class="dropdown-item" data-action="addsibling">
					<span>형제 노드</span><span>Enter</span>
				</div>
			</div>
		</div>
		<div class="menu-item" data-menu="tools">Tools</div>
		<div class="menu-item" data-menu="help">Help</div>
	</div>

        <!-- 툴바 -->
        <div class="toolbar">
                <button class="toolbar-button" data-action="new">
                        📄
			<div class="tooltip">새 마인드맵 (Ctrl+N)</div>
		</button>
		<button class="toolbar-button" data-action="open">
			📁
			<div class="tooltip">열기 (Ctrl+O)</div>
		</button>
		<button class="toolbar-button" data-action="save">
			💾
			<div class="tooltip">저장 (Ctrl+S)</div>
		</button>
		<div class="toolbar-separator"></div>
		<button class="toolbar-button" data-action="undo">
			↶
			<div class="tooltip">실행취소 (Ctrl+Z)</div>
		</button>
		<button class="toolbar-button" data-action="redo">
			↷
			<div class="tooltip">다시실행 (Ctrl+Y)</div>
		</button>
		<div class="toolbar-separator"></div>
		<button class="toolbar-button" data-action="addnode">
			➕
			<div class="tooltip">노드 추가 (Insert)</div>
		</button>
		<button class="toolbar-button" data-action="delete">
			🗑️
			<div class="tooltip">삭제 (Del)</div>
		</button>
		<button class="toolbar-button" data-action="connect">
			🔗
			<div class="tooltip">연결 모드</div>
		</button>
		<div class="toolbar-separator"></div>
		<button class="toolbar-button" data-action="zoomin">
			🔍
			<div class="tooltip">확대 (Ctrl++)</div>
		</button>
		<button class="toolbar-button" data-action="zoomout">
			🔍
			<div class="tooltip">축소 (Ctrl+-)</div>
		</button>
                <button class="toolbar-button" data-action="zoomfit">
                        🎯
                        <div class="tooltip">전체보기 (Ctrl+0)</div>
                </button>
        </div>

        <!-- 협업 상태 바 -->
        <div class="collaboration-bar">
                <div class="collab-status">
                        <span class="connection-indicator" id="collaboration-indicator" data-state="disconnected"></span>
                        <div class="collab-status-text">
                                <strong id="collaboration-status-text">오프라인</strong>
                                <small id="collaboration-latency">연결 대기 중</small>
                        </div>
                </div>
                <div class="collab-presence">
                        <span class="presence-label">현재 참여자</span>
                        <div class="presence-avatars" id="collaboration-avatars"></div>
                </div>
                <div class="collab-actions">
                        <button class="collab-btn" data-action="share">공유 링크</button>
                        <button class="collab-btn" data-action="resync">동기화 점검</button>
                        <button class="collab-btn" data-action="toggle-offline">오프라인 모드</button>
                </div>
        </div>

	<!-- 메인 컨테이너 -->
	<div class="main-container">
		<!-- 왼쪽 패널: 프로젝트 익스플로러 -->
		<div class="left-panel">
			<div class="panel-header">
				📁 프로젝트 익스플로러
				<div class="panel-controls">
					<button class="panel-btn" data-action="refresh">🔄</button>
					<button class="panel-btn" data-action="collapse">📁</button>
				</div>
			</div>
                        <div class="panel-content">
                                <div class="project-tree" id="project-tree"></div>
                        </div>
		</div>

		<!-- 중앙 에디터 영역 -->
		<div class="editor-area">
			<div class="editor-tabs">
				<div class="editor-tab active modified" data-file="새 마인드맵.mindmap">
					🗺️ 새 마인드맵.mindmap <span class="close-btn" data-action="closetab">×</span>
				</div>
			</div>

			<div class="canvas-container">
				<canvas id="mindmap-canvas"></canvas>

				<!-- 초기 샘플 노드들 -->
				<div class="mind-node root" id="node-1"
					style="left: 400px; top: 250px;" data-id="1">중심 아이디어</div>
				<div class="mind-node" id="node-2" style="left: 200px; top: 150px;"
					data-id="2" data-parent="1">서브 토픽 1</div>
				<div class="mind-node" id="node-3" style="left: 600px; top: 150px;"
					data-id="3" data-parent="1">서브 토픽 2</div>
				<div class="mind-node" id="node-4" style="left: 200px; top: 350px;"
					data-id="4" data-parent="1">서브 토픽 3</div>

				<!-- 줌 컨트롤 -->
				<div class="zoom-controls">
					<button class="zoom-btn" data-action="zoomin">+</button>
					<div class="zoom-level">100%</div>
					<button class="zoom-btn" data-action="zoomout">-</button>
				</div>

				<!-- 미니맵 -->
				<div class="minimap">
					<canvas id="minimap-canvas" width="200" height="120"></canvas>
				</div>
			</div>
		</div>

		<!-- 오른쪽 패널: 속성 -->
		<div class="right-panel">
			<div class="panel-header">
				🔧 속성
				<div class="panel-controls">
					<button class="panel-btn" data-action="reset">↺</button>
				</div>
			</div>
                        <div class="panel-content">
                                <div class="properties-section">
                                        <div class="property-item">
						<span class="property-label">노드 텍스트:</span> <input type="text"
							class="property-input" id="prop-text" value="">
					</div>
					<div class="property-item">
						<span class="property-label">배경색:</span> <input type="color"
							class="property-input" id="prop-bgcolor" value="#505050">
					</div>
					<div class="property-item">
						<span class="property-label">글자 색:</span> <input type="color"
							class="property-input" id="prop-color" value="#ffffff">
					</div>
					<div class="property-item">
						<span class="property-label">글자 크기:</span> <input type="number"
							class="property-input" id="prop-fontsize" value="14" min="8"
							max="24">
					</div>
					<div class="property-item">
						<span class="property-label">테두리 색:</span> <input type="color"
							class="property-input" id="prop-bordercolor" value="#666666">
					</div>
					<div class="property-item">
						<span class="property-label">X 좌표:</span> <input type="number"
							class="property-input" id="prop-x" value="0">
					</div>
                                        <div class="property-item">
                                                <span class="property-label">Y 좌표:</span> <input type="number"
                                                        class="property-input" id="prop-y" value="0">
                                        </div>
                                </div>
                                <div class="collaboration-panel">
                                        <div class="collaboration-panel-title">실시간 활동</div>
                                        <div class="collaboration-activity" id="collaboration-activity"></div>
                                </div>
                                <div class="collaboration-panel">
                                        <div class="collaboration-panel-title">동기화 상태</div>
                                        <ul class="sync-status" id="sync-status">
                                                <li>
                                                        <span>문서 버전</span><span id="collaboration-version">v0</span>
                                                </li>
                                                <li>
                                                        <span>마지막 업데이트</span><span id="collaboration-updated-at">-</span>
                                                </li>
                                        </ul>
                                </div>
                        </div>
                </div>
        </div>

	<!-- 하단 패널: 콘솔 -->
	<div class="bottom-panel">
		<div class="panel-header">
			📝 콘솔
			<div class="panel-controls">
				<button class="panel-btn" data-action="clear">🗑️</button>
			</div>
		</div>
		<div class="console-content" id="console">
			<div class="log-info">[INFO] 마인드맵 에디터 초기화 완료</div>
			<div class="log-info">[INFO] 캔버스 크기: 800x600</div>
			<div class="log-info">[INFO] 노드 4개 로드됨</div>
			<div class="log-debug">[DEBUG] 드래그 앤 드롭 이벤트 리스너 등록</div>
		</div>
	</div>

	<!-- 상태바 -->
	<div class="status-bar">
		<div class="status-left">
			<span class="status-item" id="status-mode">선택 모드</span> <span
				class="status-item" id="status-selection">선택: 없음</span>
		</div>
                <div class="status-right">
                        <span class="status-item" id="status-zoom">줌: 100%</span> <span
                                class="status-item" id="status-nodes">노드: 4개</span> <span
                                class="status-item" id="status-connections">연결: 3개</span> <span
                                class="status-item" id="status-collaboration">협업: 오프라인</span> <span
                                class="status-item">UTF-8</span>
                </div>
        </div>

	<!-- 컨텍스트 메뉴 -->
	<div class="context-menu" id="context-menu">
		<div class="context-menu-item" data-action="addnode">
			<span>새 노드 추가</span><span>Insert</span>
		</div>
		<div class="context-menu-item" data-action="addchild">
			<span>하위 노드 추가</span><span>Tab</span>
		</div>
		<div class="context-menu-item" data-action="addsibling">
			<span>형제 노드 추가</span><span>Enter</span>
		</div>
		<div class="context-menu-separator"></div>
		<div class="context-menu-item" data-action="cut">
			<span>잘라내기</span><span>Ctrl+X</span>
		</div>
		<div class="context-menu-item" data-action="copy">
			<span>복사</span><span>Ctrl+C</span>
		</div>
		<div class="context-menu-item" data-action="paste">
			<span>붙여넣기</span><span>Ctrl+V</span>
		</div>
		<div class="context-menu-item" data-action="delete">
			<span>삭제</span><span>Del</span>
		</div>
		<div class="context-menu-separator"></div>
		<div class="context-menu-item" data-action="properties">
			<span>속성</span>
		</div>
	</div>

	
<script defer src="mindmap.js"></script>

</body>
</html>
