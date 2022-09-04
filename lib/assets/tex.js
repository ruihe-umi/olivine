window.MathJax = {
  loader: {
    load: ['[tex]/mathtools']
  },
  tex: {
    inlineMath: [
      ['$', '$'],
      ['\\(', '\\)']
    ],
    packages: {
      '[+]': ['mathtools']
    },
    macros: {
      jparallel: '/\\!/',
      arc: ['\\overset{\\huge\\frown}{\\mathrm{#1}}', 1],
      dfrac: ['\\genfrac{}{}{0.12mm}{0}{\\;#1\\;}{\\;#2\\;}', 2],
    }
  },
  startup: {
    ready: () => {
      MathJax.startup.defaultReady();
      MathJax.startup.promise.then(() => {
        resizeSpan();
      });
    }
  }
};

function resizeSpan(element = undefined) {
  let cnt = 0
  element ||= document;
  const containers = element.querySelectorAll('foreignObject');
  for (const container of containers) {
    const content = container.querySelector('span');
    const contentWidth = content.offsetWidth
    const contentHeight = content.offsetHeight
    container.setAttribute('width', contentWidth);
    const x = Number(container.getAttribute('x')) - contentWidth / 2;
    container.setAttribute('x', x);
    const y = Number(container.getAttribute('y')) - contentHeight / 2;
    container.setAttribute('height', contentHeight);
    container.setAttribute('y', y);
    container.classList.add('loaded');
  }
};
