import { execSync } from 'child_process';

const startYear = 2025;
const endYear = new Date().getFullYear();

function getCommitSha() {
    try {
        const fullSha = execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim();
        return {
            full: fullSha,
            short: fullSha.substring(0, 7)
        };
    } catch (error) {
        console.warn('Failed to get git commit SHA:', error.message);
        return null;
    }
}

export default {
    title: "WSIM",
    language: "en",
    description: "WenSim's blog site",
    startYear: startYear,
    endYear: endYear,
    copyrightYearRange: startYear === endYear ? startYear.toString() : `${startYear}-${endYear}`,
    author: {
        name: "Jeremy Gao",
        email: "wensimerhp@gmail.com",
        github: "wensimehrp",
        x: "wensimehrp",
    },
    commitSha: getCommitSha()
}
