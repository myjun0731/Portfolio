<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>DevErrLog - 개발자 에러 지식 플랫폼</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-okaidia.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    
    <style>
        /* Global Styles */
        body { font-family: 'Noto Sans KR', sans-serif; background-color: #f8f9fa; color: #333; }
        code, pre { font-family: 'JetBrains Mono', monospace; }
        
        /* Branding */
        .brand-logo { font-weight: 700; color: #4f46e5; font-size: 1.25rem; text-decoration: none; }
        .navbar { box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
        
        /* UI Components */
        .card { border: none; box-shadow: 0 2px 8px rgba(0,0,0,0.04); transition: transform 0.2s; border-radius: 12px; }
        .card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
        
        .tag-badge { background-color: #e0e7ff; color: #4338ca; font-size: 0.8rem; margin-right: 6px; padding: 4px 10px; border-radius: 20px; text-decoration: none; font-weight: 500; }
        .tag-badge:hover { background-color: #c7d2fe; color: #312e81; }
        
        .btn-primary { background-color: #4f46e5; border-color: #4f46e5; }
        .btn-primary:hover { background-color: #4338ca; border-color: #4338ca; }
        
        /* Page Switching Logic (SPA Simulation) */
        .page-section { display: none; animation: fadeIn 0.3s ease-in-out; }
        .page-section.active { display: block; }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-white sticky-top">
    <div class="container">
        <a class="brand-logo" href="#" onclick="showPage('home')">
            &lt;DevErrLog /&gt;
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto ms-3">
                <li class="nav-item"><a class="nav-link fw-bold" href="#" onclick="showPage('home')">탐색</a></li>
                <li class="nav-item"><a class="nav-link" href="#">태그</a></li>
                <li class="nav-item"><a class="nav-link" href="#">랭킹</a></li>
            </ul>
            <div class="d-flex">
                <button onclick="showPage('write')" class="btn btn-primary me-2 shadow-sm">
                    <i class="bi bi-pencil-square"></i> 로그 기록하기
                </button>
                <button onclick="showPage('login')" class="btn btn-outline-secondary">로그인</button>
            </div>
        </div>
    </div>
</nav>

<div class="container mt-4 mb-5" style="min-height: 80vh;">

    <div id="page-home" class="page-section active">
        <div class="text-center py-5">
            <h1 class="fw-bold mb-3 display-6">어떤 에러를 마주하셨나요?</h1>
            <p class="text-muted mb-4">개발자들의 에러 로그 데이터베이스에서 해결책을 찾아보세요.</p>
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="input-group input-group-lg shadow-sm">
                        <span class="input-group-text bg-white border-end-0"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-search" viewBox="0 0 16 16"><path d="M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z"/></svg></span>
                        <input type="text" class="form-control border-start-0" placeholder="에러 메시지, 태그, 예외명을 검색해보세요...">
                        <button class="btn btn-primary px-4" type="button">검색</button>
                    </div>
                    <div class="mt-3 text-start ps-2 small text-muted">
                        <span class="badge bg-light text-dark border me-1">🔥 추천</span>
                        <a href="#" class="text-decoration-none me-2">#NullPointerException</a>
                        <a href="#" class="text-decoration-none me-2">#React_Hooks</a>
                        <a href="#" class="text-decoration-none me-2">#CORS</a>
                    </div>
                </div>
            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold m-0">최신 에러 로그</h4>
            <div class="btn-group" role="group">
                <button type="button" class="btn btn-sm btn-outline-primary active">최신순</button>
                <button type="button" class="btn btn-sm btn-outline-primary">인기순</button>
                <button type="button" class="btn btn-sm btn-outline-primary">해결됨</button>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-12">
                <div class="card p-4" onclick="showPage('detail')" style="cursor: pointer;">
                    <div class="d-flex justify-content-between mb-2">
                        <h5 class="card-title fw-bold text-primary mb-0">Spring Boot JPA N+1 문제 해결 로그 (EntityGraph)</h5>
                        <small class="text-muted">10분 전</small>
                    </div>
                    <p class="card-text text-secondary text-truncate">FetchType.LAZY 설정 후에도 발생하는 N+1 쿼리 문제 분석 및 @EntityGraph 적용 사례입니다.</p>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <div>
                            <span class="tag-badge">#SpringDataJPA</span>
                            <span class="tag-badge">#Performance</span>
                        </div>
                        <div class="small text-muted">
                            <span class="me-2">❤️ 12</span> <span class="me-2">💬 4</span> <span class="text-success fw-bold">✓ Solved</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-12">
                <div class="card p-4" onclick="showPage('detail')" style="cursor: pointer;">
                    <div class="d-flex justify-content-between mb-2">
                        <h5 class="card-title fw-bold text-dark mb-0">React useEffect 무한 루프 발생 원인 및 해결</h5>
                        <small class="text-muted">1시간 전</small>
                    </div>
                    <p class="card-text text-secondary text-truncate">객체형 의존성 배열(Dependency Array) 처리 실수로 인한 리렌더링 이슈 기록.</p>
                    <div class="d-flex justify-content-between align-items-center mt-2">
                        <div>
                            <span class="tag-badge">#React</span>
                            <span class="tag-badge">#Hooks</span>
                        </div>
                        <div class="small text-muted">
                            <span class="me-2">❤️ 5</span> <span class="me-2">💬 1</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <nav class="mt-5">
            <ul class="pagination justify-content-center">
                <li class="page-item disabled"><a class="page-link" href="#">이전</a></li>
                <li class="page-item active"><a class="page-link" href="#">1</a></li>
                <li class="page-item"><a class="page-link" href="#">2</a></li>
                <li class="page-item"><a class="page-link" href="#">다음</a></li>
            </ul>
        </nav>
    </div>

    <div id="page-detail" class="page-section">
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="#" onclick="showPage('home')">Home</a></li>
                <li class="breadcrumb-item active">Log #2512</li>
            </ol>
        </nav>

        <div class="row">
            <div class="col-lg-9">
                <div class="card mb-4">
                    <div class="card-body p-4">
                        <h2 class="fw-bold mb-3">Spring Boot JPA N+1 문제와 해결 (EntityGraph)</h2>
                        
                        <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-4">
                            <div class="d-flex align-items-center">
                                <div class="bg-primary rounded-circle text-white d-flex justify-content-center align-items-center me-2" style="width: 32px; height: 32px; font-size:0.8rem;">JD</div>
                                <div>
                                    <span class="fw-bold d-block lh-1">JavaDev</span>
                                    <span class="text-muted small">2024-05-20 14:30</span>
                                </div>
                            </div>
                            <div>
                                <button class="btn btn-outline-primary btn-sm me-1">🔖 북마크</button>
                                <button class="btn btn-outline-danger btn-sm">🚨 신고</button>
                            </div>
                        </div>

                        <div class="mb-4">
                            <span class="badge bg-danger mb-2">Error Log</span>
                            <br>
                            <span class="tag-badge">#SpringDataJPA</span>
                            <span class="tag-badge">#N+1_Problem</span>
                            <span class="tag-badge">#Optimization</span>
                        </div>

                        <h5 class="fw-bold mt-4 border-start border-4 border-danger ps-2">1. 문제 상황 (Problem)</h5>
                        <p class="text-secondary">
                            Team 목록을 조회할 때, 각 팀에 속한 Member들을 지연 로딩(Lazy Loading)으로 설정했음에도 불구하고,
                            팀 개수만큼 추가 쿼리가 발생하는 N+1 문제가 발견되었습니다.
                        </p>

                        <h5 class="fw-bold mt-4 border-start border-4 border-warning ps-2">2. 발생 코드 (Code)</h5>
                        <pre class="rounded"><code class="language-java">// TeamRepository.java
// 단순히 findAll을 호출할 때 연관된 Member를 가져오기 위해 쿼리가 반복 실행됨
List<Team> findAll(); 
</code></pre>

                        <h5 class="fw-bold mt-4 border-start border-4 border-success ps-2">3. 해결 방법 (Solution)</h5>
                        <p class="text-secondary">
                            JPQL의 <code>join fetch</code>를 사용하거나, Spring Data JPA의 <code>@EntityGraph</code>를 사용하여 해결했습니다.
                            가독성을 위해 어노테이션 기반의 EntityGraph 방식을 채택했습니다.
                        </p>
<pre class="rounded"><code class="language-java">// TeamRepository.java (Fixed)
// attributePaths에 바로 로딩할 연관 엔티티 명시
@EntityGraph(attributePaths = "members")
List<Team> findAll();
</code></pre>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header bg-white fw-bold py-3">
                        지식 공유 (Comments) <span class="text-primary">2</span>
                    </div>
                    <div class="card-body">
                        <div class="d-flex mb-4">
                            <div class="flex-shrink-0 me-3">
                                <div class="bg-light rounded-circle border d-flex justify-content-center align-items-center" style="width: 40px; height: 40px;">S</div>
                            </div>
                            <div class="flex-grow-1">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <h6 class="fw-bold mb-0">SeniorDev</h6>
                                    <small class="text-muted">1시간 전</small>
                                </div>
                                <p class="text-secondary mb-2">BatchSize 설정으로도 해결 가능하지 않을까요? 리스트 크기가 크다면 고려해볼 만합니다.</p>
                                <button class="btn btn-sm btn-light text-primary py-0" style="font-size: 0.8rem;">👍 좋아요 3</button>
                            </div>
                        </div>
                        
                        <form class="bg-light p-3 rounded">
                            <textarea class="form-control mb-2" rows="3" placeholder="추가적인 해결책이나 질문을 남겨주세요 (Markdown 지원)"></textarea>
                            <div class="text-end">
                                <button type="button" class="btn btn-primary btn-sm">댓글 등록</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <div class="col-lg-3">
                <div class="card mb-3">
                    <div class="card-body">
                        <h6 class="card-title fw-bold mb-3">관련 로그</h6>
                        <ul class="list-unstyled small mb-0">
                            <li class="mb-2"><a href="#" class="text-decoration-none text-secondary">Hibernate FetchMode 차이점</a></li>
                            <li class="mb-2"><a href="#" class="text-decoration-none text-secondary">QueryDSL을 이용한 최적화</a></li>
                            <li class="mb-2"><a href="#" class="text-decoration-none text-secondary">JPA 영속성 컨텍스트 이해</a></li>
                        </ul>
                    </div>
                </div>
                <div class="card bg-light border-0">
                    <div class="card-body text-center">
                        <p class="small text-muted mb-2">이 로그가 도움이 되었나요?</p>
                        <button class="btn btn-outline-primary w-100 bg-white">👍 추천하기 (12)</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="page-write" class="page-section">
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-5">
                        <h3 class="fw-bold mb-4">새로운 에러 로그 기록</h3>
                        <p class="text-muted mb-4">당신의 에러 해결 경험이 누군가에게는 정답이 됩니다.</p>
                        
                        <form>
                            <div class="mb-4">
                                <label class="form-label fw-bold">에러 제목</label>
                                <input type="text" class="form-control form-control-lg" placeholder="예: IllegalArgumentException: Invalid id value...">
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold">태그 (Tags)</label>
                                <input type="text" class="form-control" placeholder="태그를 쉼표(,)로 구분해 입력하세요 (예: java, spring, error)">
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold">발생 코드 (Code Snippet)</label>
                                <textarea class="form-control font-monospace bg-dark text-light border-0" rows="6" placeholder="// 문제가 발생한 코드를 붙여넣으세요."></textarea>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold">문제 상황 및 해결 과정</label>
                                <textarea class="form-control" rows="10" placeholder="1. 어떤 상황이었나요?&#13;&#10;2. 무엇을 시도했나요?&#13;&#10;3. 어떻게 해결했나요? (Markdown 지원)"></textarea>
                            </div>

                            <div class="d-flex justify-content-end gap-2">
                                <button type="button" class="btn btn-light" onclick="showPage('home')">취소</button>
                                <button type="button" class="btn btn-secondary">임시 저장</button>
                                <button type="button" class="btn btn-primary px-4" onclick="alert('등록되었습니다!'); showPage('home');">로그 등록</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="page-login" class="page-section">
        <div class="row justify-content-center align-items-center" style="min-height: 60vh;">
            <div class="col-md-5">
                <div class="card shadow-lg border-0">
                    <div class="card-body p-5 text-center">
                        <h3 class="fw-bold text-primary mb-4">&lt;DevErrLog /&gt;</h3>
                        <h5 class="mb-3">개발자 로그인</h5>
                        <form>
                            <div class="form-floating mb-3">
                                <input type="email" class="form-control" id="floatingInput" placeholder="name@example.com">
                                <label for="floatingInput">이메일 주소</label>
                            </div>
                            <div class="form-floating mb-4">
                                <input type="password" class="form-control" id="floatingPassword" placeholder="Password">
                                <label for="floatingPassword">비밀번호</label>
                            </div>
                            <button class="btn btn-primary w-100 py-2 mb-3" type="button" onclick="showPage('home')">로그인</button>
                            <div class="text-muted small">
                                아직 계정이 없으신가요? <a href="#" class="text-decoration-none">회원가입</a>
                            </div>
                        </form>
                        <hr class="my-4">
                        <button class="btn btn-outline-dark w-100 mb-2">
                            <i class="bi bi-github"></i> GitHub으로 계속하기
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div> <footer class="bg-white border-top py-4 mt-auto">
    <div class="container text-center text-muted">
        <div class="mb-2">
            <span class="brand-logo" style="font-size: 1rem;">&lt;DevErrLog /&gt;</span>
        </div>
        <p class="small mb-0">
            DevErrLog는 에러가 학습 데이터가 되는 개발 생태계를 지향합니다.<br>
            &copy; 2024 DevErrLog Team. All rights reserved.
        </p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-java.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-javascript.min.js"></script>

<script>
    // Simple SPA Routing Logic
    function showPage(pageId) {
        // 1. Hide all pages
        document.querySelectorAll('.page-section').forEach(section => {
            section.classList.remove('active');
        });

        // 2. Show requested page
        const targetPage = document.getElementById('page-' + pageId);
        if (targetPage) {
            targetPage.classList.add('active');
        }

        // 3. Scroll to top
        window.scrollTo(0, 0);

        // 4. Highlight Syntax (if newly shown)
        if(pageId === 'detail') {
            Prism.highlightAll();
        }
    }
</script>

</body>
</html>