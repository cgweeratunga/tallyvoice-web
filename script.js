const menuToggle = document.querySelector('.menu-toggle');
const siteNav = document.querySelector('.site-nav');
const prompts = document.querySelectorAll('.prompt');
const answer = document.querySelector('#dynamic-answer');
const signupForm = document.querySelector('#signup-form');
const formMessage = document.querySelector('#form-message');
const year = document.querySelector('#current-year');

if (menuToggle && siteNav) {
  menuToggle.addEventListener('click', () => {
    const isOpen = siteNav.classList.toggle('open');
    menuToggle.setAttribute('aria-expanded', String(isOpen));
  });

  siteNav.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', () => {
      siteNav.classList.remove('open');
      menuToggle.setAttribute('aria-expanded', 'false');
    });
  });
}

prompts.forEach((prompt) => {
  prompt.addEventListener('click', () => {
    prompts.forEach((item) => item.classList.remove('active'));
    prompt.classList.add('active');
    answer.textContent = prompt.dataset.answer;
  });
});

if (signupForm) {
  signupForm.addEventListener('submit', (event) => {
    event.preventDefault();
    const data = new FormData(signupForm);
    const name = data.get('name');
    formMessage.textContent = `Thanks ${name}. Your early-access request has been recorded.`;
    signupForm.reset();
  });
}

if (year) {
  year.textContent = new Date().getFullYear();
}
