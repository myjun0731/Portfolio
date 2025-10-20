<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MindMap IDE - Demo</title>

<link rel="stylesheet" href="mindmap.css">

</head>
<body>
        <div class="app-shell">
                <header class="app-header" role="banner">
                        <div class="brand">
                                <span class="brand-logo">CollaMind</span>
                                <span class="brand-subtitle">아이디어를 구조화하고 팀과 공유하세요</span>
                        </div>
                        <div class="header-actions">
                                <div class="autosave-indicator" id="autosave-indicator" data-state="saved" aria-live="polite">
                                        저장됨
                                </div>
                                <div class="header-buttons">
                                        <button class="header-btn app-action" type="button" data-action="new">
                                                <span class="btn-icon">＋</span>
                                                새 마인드맵
                                        </button>
                                        <button class="header-btn app-action" type="button" data-action="save">
                                                <span class="btn-icon">💾</span>
                                                저장
                                        </button>
                                        <button class="header-btn app-action" type="button" data-action="toggletheme">
                                                <span class="btn-icon">🌓</span>
                                                테마 전환
                                        </button>
                                </div>
                        </div>
                </header>

        <!-- 메뉴바 -->
        <div class="menu-bar" role="menubar">
                <div class="menu-item" data-menu="file" role="menuitem" aria-haspopup="true" tabindex="0">
                        File
                        <div class="dropdown-menu">
                                <div class="dropdown-item" data-action="new" role="menuitem" tabindex="0">
					<span>새 마인드맵</span><span>Ctrl+N</span>
				</div>
                                <div class="dropdown-item" data-action="open" role="menuitem" tabindex="0">
					<span>열기</span><span>Ctrl+O</span>
				</div>
                                <div class="dropdown-item" data-action="save" role="menuitem" tabindex="0">
					<span>저장</span><span>Ctrl+S</span>
				</div>
                                <div class="dropdown-item" data-action="saveas" role="menuitem" tabindex="0">
					<span>다른 이름으로 저장</span><span>Ctrl+Shift+S</span>
				</div>
				<div class="dropdown-separator"></div>
                                <div class="dropdown-item" data-action="export" role="menuitem" tabindex="0">
					<span>내보내기</span>
				</div>
                                <div class="dropdown-item" data-action="print" role="menuitem" tabindex="0">
					<span>인쇄</span><span>Ctrl+P</span>
                                </div>
                        </div>
                </div>
                <div class="menu-item" data-menu="edit" role="menuitem" aria-haspopup="true" tabindex="0">
			Edit
			<div class="dropdown-menu">
                                <div class="dropdown-item" data-action="undo" role="menuitem" tabindex="0">
					<span>실행취소</span><span>Ctrl+Z</span>
				</div>
                                <div class="dropdown-item" data-action="redo" role="menuitem" tabindex="0">
					<span>다시실행</span><span>Ctrl+Y</span>
				</div>
				<div class="dropdown-separator"></div>
                                <div class="dropdown-item" data-action="cut" role="menuitem" tabindex="0">
					<span>잘라내기</span><span>Ctrl+X</span>
				</div>
                                <div class="dropdown-item" data-action="copy" role="menuitem" tabindex="0">
					<span>복사</span><span>Ctrl+C</span>
				</div>
                                <div class="dropdown-item" data-action="paste" role="menuitem" tabindex="0">
					<span>붙여넣기</span><span>Ctrl+V</span>
				</div>
                                <div class="dropdown-item" data-action="delete" role="menuitem" tabindex="0">
					<span>삭제</span><span>Del</span>
				</div>
				<div class="dropdown-separator"></div>
                                <div class="dropdown-item" data-action="selectall" role="menuitem" tabindex="0">
					<span>모두 선택</span><span>Ctrl+A</span>
				</div>
                        </div>
                </div>
                <div class="menu-item" data-menu="view" role="menuitem" aria-haspopup="true" tabindex="0">
			View
			<div class="dropdown-menu">
                                <div class="dropdown-item" data-action="zoomin" role="menuitem" tabindex="0">
					<span>확대</span><span>Ctrl++</span>
				</div>
                                <div class="dropdown-item" data-action="zoomout" role="menuitem" tabindex="0">
					<span>축소</span><span>Ctrl+-</span>
				</div>
                                <div class="dropdown-item" data-action="zoomfit" role="menuitem" tabindex="0">
					<span>전체보기</span><span>Ctrl+0</span>
				</div>
				<div class="dropdown-separator"></div>
                                <div class="dropdown-item" data-action="grid" role="menuitem" tabindex="0">
					<span>격자 표시</span>
				</div>
                                <div class="dropdown-item" data-action="minimap" role="menuitem" tabindex="0">
					<span>미니맵</span>
                                </div>
                        </div>
                </div>
                <div class="menu-item" data-menu="insert" role="menuitem" aria-haspopup="true" tabindex="0">
                        Insert
                        <div class="dropdown-menu">
                                <div class="dropdown-item" data-action="addnode" role="menuitem" tabindex="0">
					<span>노드 추가</span><span>Insert</span>
				</div>
                                <div class="dropdown-item" data-action="addchild" role="menuitem" tabindex="0">
					<span>하위 노드</span><span>Tab</span>
				</div>
                                <div class="dropdown-item" data-action="addsibling" role="menuitem" tabindex="0">
					<span>형제 노드</span><span>Enter</span>
                                </div>
                        </div>
                </div>
                <div class="menu-item" data-menu="tools" role="menuitem" aria-haspopup="true" tabindex="0">
                        Tools
                        <div class="dropdown-menu">
                                <div class="dropdown-item" data-action="toggleleftpanel" role="menuitem" tabindex="0">
                                        <span>왼쪽 패널 토글</span>
                                        <span>Alt+1</span>
                                </div>
                                <div class="dropdown-item" data-action="togglerightpanel" role="menuitem" tabindex="0">
                                        <span>오른쪽 패널 토글</span>
                                        <span>Alt+2</span>
                                </div>
                                <div class="dropdown-item" data-action="panmode" role="menuitem" tabindex="0">
                                        <span>이동 모드</span>
                                        <span>Alt+M</span>
                                </div>
                                <div class="dropdown-item" data-action="selectmode" role="menuitem" tabindex="0">
                                        <span>선택 모드</span>
                                        <span>Alt+S</span>
                                </div>
                                <div class="dropdown-item" data-action="resetview" role="menuitem" tabindex="0">
                                        <span>뷰 초기화</span>
                                        <span>Alt+0</span>
                                </div>
                                <div class="dropdown-separator"></div>
                                <div class="dropdown-item" data-action="toggletheme" role="menuitem" tabindex="0">
                                        <span>테마 전환</span>
                                        <span>Alt+T</span>
                                </div>
                        </div>
                </div>
                <div class="menu-item" data-menu="help" role="menuitem" aria-haspopup="true" tabindex="0">
                        Help
                        <div class="dropdown-menu">
                                <div class="dropdown-item" data-action="showshortcuts" role="menuitem" tabindex="0">
                                        <span>단축키 안내</span>
                                </div>
                                <div class="dropdown-item" data-action="showabout" role="menuitem" tabindex="0">
                                        <span>CollaMind 정보</span>
                                </div>
                        </div>
                </div>
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

        <!-- 메인 컨테이너 -->
        <div class="main-container">
                <!-- 왼쪽 패널: 프로젝트 익스플로러 -->
                <div class="left-panel">
                        <div class="panel-header">
                                <span class="panel-title">📁 프로젝트 익스플로러</span>
                                <div class="panel-controls">
                                        <button class="panel-btn" data-action="refresh" title="프로젝트 새로고침">🔄</button>
                                        <button class="panel-btn" data-action="collapse" title="폴더 펼치기/접기">📁</button>
                                        <button class="panel-btn" data-action="toggleleftpanel" title="왼쪽 패널 숨기기">⬅️</button>
                                </div>
                        </div>
                        <div class="panel-toolbar">
                                <label class="search-field" for="project-search">
                                        <span class="search-icon">🔍</span>
                                        <input type="search" id="project-search" placeholder="파일 또는 폴더 검색" autocomplete="off">
                                        <button type="button" class="clear-search" id="project-search-clear" aria-label="검색 지우기">×</button>
                                </label>
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
                                        <button class="panel-btn" data-action="resetproperties" title="선택한 노드 스타일 초기화">↺</button>
                                        <button class="panel-btn" data-action="togglerightpanel" title="오른쪽 패널 숨기기">➡️</button>
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
                <div class="console-content" id="console" role="log" aria-live="polite">
                        <div class="log-info">[INFO] 마인드맵 에디터 초기화 완료</div>
                        <div class="log-info">[INFO] 캔버스 크기: 800x600</div>
                        <div class="log-info">[INFO] 노드 4개 로드됨</div>
			<div class="log-debug">[DEBUG] 드래그 앤 드롭 이벤트 리스너 등록</div>
		</div>
	</div>

	<!-- 상태바 -->
        <div class="status-bar">
                <div class="status-left">
                        <span class="status-item" id="status-mode" data-action="cyclemode" role="button" tabindex="0">선택 모드</span>
                        <span class="status-item" id="status-selection">선택: 없음</span>
                </div>
                <div class="status-right">
                        <span class="status-item" id="status-zoom" data-action="resetview" role="button" tabindex="0">줌: 100%</span>
                        <span class="status-item" id="status-nodes">노드: 4개</span>
                        <span class="status-item" id="status-connections">연결: 3개</span>
                        <span class="status-item" data-action="showshortcuts" role="button" tabindex="0">단축키</span>
                        <span class="status-item">UTF-8</span>
                </div>
        </div>

        <!-- 컨텍스트 메뉴 -->
        <div class="context-menu" id="context-menu">
                <div class="context-menu-item" data-action="addnode" role="menuitem" tabindex="0">
			<span>새 노드 추가</span><span>Insert</span>
		</div>
                <div class="context-menu-item" data-action="addchild" role="menuitem" tabindex="0">
			<span>하위 노드 추가</span><span>Tab</span>
		</div>
                <div class="context-menu-item" data-action="addsibling" role="menuitem" tabindex="0">
			<span>형제 노드 추가</span><span>Enter</span>
		</div>
		<div class="context-menu-separator"></div>
                <div class="context-menu-item" data-action="cut" role="menuitem" tabindex="0">
			<span>잘라내기</span><span>Ctrl+X</span>
		</div>
                <div class="context-menu-item" data-action="copy" role="menuitem" tabindex="0">
			<span>복사</span><span>Ctrl+C</span>
		</div>
                <div class="context-menu-item" data-action="paste" role="menuitem" tabindex="0">
			<span>붙여넣기</span><span>Ctrl+V</span>
		</div>
                <div class="context-menu-item" data-action="delete" role="menuitem" tabindex="0">
			<span>삭제</span><span>Del</span>
		</div>
		<div class="context-menu-separator"></div>
                <div class="context-menu-item" data-action="properties" role="menuitem" tabindex="0">
			<span>속성</span>
                </div>
        </div>


        <!-- 모달 -->
        <div class="modal-overlay" id="app-modal" hidden tabindex="-1" role="dialog" aria-modal="true">
                <div class="modal-dialog">
                        <div class="modal-header">
                                <h2 class="modal-title" id="modal-title">CollaMind</h2>
                                <button class="modal-close" data-action="closemodal" aria-label="모달 닫기">×</button>
                        </div>
                        <div class="modal-body" id="modal-body"></div>
                        <div class="modal-footer">
                                <button class="primary-btn" data-action="closemodal">닫기</button>
                        </div>
                </div>
        </div>

        <div class="toast-stack" id="toast-stack" aria-live="polite" aria-atomic="true"></div>

<script defer src="mindmap.js"></script>

        </div>
</body>
</html>
