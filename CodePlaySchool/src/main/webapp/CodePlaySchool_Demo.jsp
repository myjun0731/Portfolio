<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodePlaySchool - Demo</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    
    <link rel="stylesheet" href="assets/css/codeplayschool-demo.css">

</head>
<body>

<%
    String currentRole = (String) session.getAttribute("userRole");
    if (currentRole == null) {
        currentRole = "student";
        session.setAttribute("userRole", currentRole);
    }
    
    String currentPage = request.getParameter("page");
    if (currentPage == null) {
        if ("student".equals(currentRole)) currentPage = "s.dashboard";
        else if ("teacher".equals(currentRole)) currentPage = "t.classes";
        else currentPage = "a.monitor";
    }
%>

<script>
    window.__INITIAL_STATE__ = {
        role: '<%= currentRole %>',
        page: '<%= currentPage %>'
    };
</script>

<div class="flex h-screen w-full overflow-hidden bg-gray-50">
    <!-- Sidebar -->
    <div class="sidebar flex h-full w-64 flex-col gap-4 border-r border-gray-100 bg-white p-3">
        <div class="flex items-center gap-2 px-2">
            <div class="flex h-9 w-9 items-center justify-center rounded-2xl bg-black text-white">
                <i data-lucide="sparkles" class="h-5 w-5"></i>
            </div>
            <div>
                <div class="text-sm font-semibold">CodePlay School</div>
                <div class="text-xs text-gray-500">Demo Version</div>
            </div>
        </div>

        <div class="card card-body">
            <div class="mb-2 text-xs font-medium text-gray-500">역할 전환</div>
            <div class="grid grid-cols-3 gap-2">
                <button onclick="changeRole('student')" 
                    class="role-btn <%= currentRole.equals("student") ? "active" : "" %> rounded-xl px-2 py-1 text-sm"
                    data-role="student">학생</button>
                <button onclick="changeRole('teacher')" 
                    class="role-btn <%= currentRole.equals("teacher") ? "active" : "" %> rounded-xl px-2 py-1 text-sm"
                    data-role="teacher">교사</button>
                <button onclick="changeRole('admin')" 
                    class="role-btn <%= currentRole.equals("admin") ? "active" : "" %> rounded-xl px-2 py-1 text-sm"
                    data-role="admin">관리자</button>
            </div>
        </div>

        <nav class="flex-1 space-y-1" id="navMenu"></nav>

        <div class="mt-auto rounded-2xl border border-dashed border-gray-200 p-3 text-xs text-gray-500">
           <b>Demo 버전</b><br>
            ✅ 실시간 저장/로드 예정<br>
            ✅ 블록 코딩 지원 예정 <br>
            ✅ 코드 변환 기능 추가 예정
        </div>
    </div>

    <!-- Main Content -->
    <div class="flex min-w-0 flex-1 flex-col">
        <div class="flex h-14 items-center justify-between border-b border-gray-100 bg-white px-4">
            <div class="flex items-center gap-3">
                <div class="rounded-xl bg-gray-100 px-2 py-1 text-xs font-medium text-gray-700">
                    <%= currentRole.toUpperCase() %>
                </div>
                <div class="hidden text-sm text-gray-500 md:block">학습 플랫폼 차세대 UI</div>
            </div>
            <div class="flex items-center gap-2">
                <span class="tag">Demo</span>
                <span class="tag">블록↔코드</span>
                <span class="tag">실시간 저장</span>
            </div>
        </div>

        <main class="h-[calc(100vh-3.5rem)] overflow-auto p-4">
            <div id="contentArea" class="fade-in"></div>
        </main>
    </div>
</div>

<div id="toast" class="toast"></div>
<div id="modal" class="modal"><div class="modal-content" id="modalContent"></div></div>

<script src="assets/js/state.js"></script>
<script src="assets/js/storage.js"></script>
<script src="assets/js/ui-utils.js"></script>
<script src="assets/js/navigation.js"></script>
<script src="assets/js/renderers.js"></script>
<script src="assets/js/workspace.js"></script>
<script src="assets/js/actions.js"></script>
<script src="assets/js/charts.js"></script>
<script src="assets/js/app-init.js"></script>

</body>
</html>
