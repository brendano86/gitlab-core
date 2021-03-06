import Vue from 'vue';
import RelatedIssuesRoot from './related_issues/components/related_issues_root.vue';

document.addEventListener('DOMContentLoaded', () => {
  const relatedIssuesRootElement = document.querySelector('.js-related-issues-root');
  if (relatedIssuesRootElement) {
    // eslint-disable-next-line no-new
    new Vue({
      el: relatedIssuesRootElement,
      components: {
        relatedIssuesRoot: RelatedIssuesRoot,
      },
      render: createElement => createElement('related-issues-root', {
        props: {
          endpoint: relatedIssuesRootElement.dataset.endpoint,
          canAddRelatedIssues: gl.utils.convertPermissionToBoolean(
            relatedIssuesRootElement.dataset.canAddRelatedIssues,
          ),
          helpPath: relatedIssuesRootElement.dataset.helpPath,
        },
      }),
    });
  }
});
