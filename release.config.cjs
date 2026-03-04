/**
 * @type {import('semantic-release').GlobalConfig}
 */
module.exports = {
  branches: [
    'main',
    { name: 'develop', channel: 'next', prerelease: 'rc' },
  ],
  plugins: [
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'angular',
        releaseRules: [
          { type: 'docs', release: 'patch' },
          { type: 'feat', release: 'minor' },
          { type: 'chore', release: 'patch' },
          { message: '**', release: 'patch' },
        ],
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES'],
        },
      },
    ],
    '@semantic-release/release-notes-generator',
    [
      '@semantic-release/exec',
      {
        prepareCmd: 'scripts/bump-chart-version.sh ${nextRelease.version}',
        publishCmd: 'scripts/helm-publish.sh ${nextRelease.version}',
      },
    ],
    [
      '@semantic-release/git',
      {
        assets: ['helm/geniro/Chart.yaml'],
        message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}',
      },
    ],
    '@semantic-release/github',
  ],
};
