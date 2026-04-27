const excelTrack = document.querySelector('.excel-track');

if (excelTrack) {
	let isDragging = false;
	let startX = 0;
	let startScrollLeft = 0;
	let dragPointerId = null;
	let isPotentialClick = false;

	const isInteractiveElement = (element) => {
		if (!element || typeof element.closest !== 'function') {
			return false;
		}

		return Boolean(element.closest('a, button, input, textarea, select, label'));
	};

	excelTrack.addEventListener('pointerdown', (event) => {
		if (isInteractiveElement(event.target)) {
			return;
		}

		isDragging = true;
		dragPointerId = event.pointerId;
		isPotentialClick = true;
		startX = event.clientX;
		startScrollLeft = excelTrack.scrollLeft;
		excelTrack.classList.add('is-dragging');
		excelTrack.setPointerCapture(event.pointerId);
	});

	excelTrack.addEventListener('pointermove', (event) => {
		if (!isDragging || event.pointerId !== dragPointerId) {
			return;
		}

		const distance = event.clientX - startX;
		if (Math.abs(distance) > 5) {
			isPotentialClick = false;
		}

		excelTrack.scrollLeft = startScrollLeft - (distance * 1.15);
	});

	const stopDragging = (event) => {
		if (!isDragging || event.pointerId !== dragPointerId) {
			return;
		}

		isDragging = false;
		dragPointerId = null;
		excelTrack.classList.remove('is-dragging');

		if (excelTrack.hasPointerCapture(event.pointerId)) {
			excelTrack.releasePointerCapture(event.pointerId);
		}

		if (!isPotentialClick) {
			event.preventDefault();
		}
	};

	excelTrack.addEventListener('pointerup', stopDragging);
	excelTrack.addEventListener('pointercancel', stopDragging);
	excelTrack.addEventListener('pointerleave', stopDragging);
}

const aboutContainer = document.querySelector('.about-container');

if (aboutContainer) {
	const skillFills = aboutContainer.querySelectorAll('.bar span[data-skill]');
	const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

	const fillSkillBars = () => {
		skillFills.forEach((fill) => {
			const widthValue = fill.getAttribute('data-skill');
			if (!widthValue) {
				return;
			}

			fill.style.width = `${widthValue}%`;
		});
	};

	if (prefersReducedMotion) {
		aboutContainer.classList.add('is-visible');
		fillSkillBars();
	} else {
		const aboutObserver = new IntersectionObserver(
			(entries, observer) => {
				entries.forEach((entry) => {
					if (!entry.isIntersecting) {
						return;
					}

					aboutContainer.classList.add('is-visible');
					fillSkillBars();
					observer.unobserve(entry.target);
				});
			},
			{
				threshold: 0.3
			}
		);

		aboutObserver.observe(aboutContainer);
	}
}

const projectsSection = document.querySelector('.projects');
const featuredProjectCards = document.querySelectorAll('.projects .project-card');

if (projectsSection && featuredProjectCards.length) {
	const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

	featuredProjectCards.forEach((card) => {
		card.classList.add('reveal-init');
	});

	const revealProjectCards = () => {
		featuredProjectCards.forEach((card, index) => {
			const delay = prefersReducedMotion ? 0 : index * 120;
			window.setTimeout(() => {
				card.classList.add('reveal-in');
			}, delay);
		});
	};

	if (prefersReducedMotion) {
		revealProjectCards();
	} else {
		const projectObserver = new IntersectionObserver(
			(entries, observer) => {
				entries.forEach((entry) => {
					if (!entry.isIntersecting) {
						return;
					}

					revealProjectCards();
					observer.unobserve(entry.target);
				});
			},
			{
				threshold: 0.22
			}
		);

		projectObserver.observe(projectsSection);
	}
}
