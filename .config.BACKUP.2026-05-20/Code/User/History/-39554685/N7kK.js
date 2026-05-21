// Admin profile data management
// Hardcoded base data with localStorage override capability
// This enables the "admin" feature: manage and search LinkedIn data

const STORAGE_KEY = "portfolio-admin";
const LINKEDIN_DATA_KEY = "linkedinProfileData";

/**
 * Default admin data - hardcoded baseline
 * These are the base values used if nothing is stored
 */
const defaultAdmin = {
  // Basic info
  name: "Diorges Gonzalez",
  title: "Senior Developer | Software Architect |Webs especialist",
  bio: "Passionate developer with 10+ years of experience building scalable solutions.",
  location: "Buenos Aires, Argentina",
  avatar: "", // URL to avatar image

  // Contact
  email: "diorges@example.com",
  github: "https://github.com/diorges",
  linkedin: "https://linkedin.com/in/diorges",
  twitter: "https://twitter.com/diorges",
  cvFile: "", // URL to CV PDF

  // Skills
  skills: [
    "JavaScript",
    "TypeScript",
    "React",
    "Node.js",
    "Python",
    "Go",
    "AWS",
    "Docker",
    "Kubernetes",
    "GraphQL",
  ],

  // Projects
  projects: [
    {
      id: 1,
      name: "Portfolio",
      description: "Personal portfolio website",
      tech: ["Vite", "TailwindCSS", "Vanilla JS"],
      github: "https://github.com/diorges/portfolio",
      demo: "",
    },
  ],

  // Metadata
  lastUpdated: new Date().toISOString(),
  dataSource: "hardcoded", // 'hardcoded' | 'linkedin' | 'manual'
};

/**
 * Get admin profile data
 * Merges hardcoded defaults with any stored overrides
 * LinkedIn data takes precedence if available
 * @returns {object}
 */
export function getAdminProfile() {
  // Start with hardcoded defaults
  let profile = { ...defaultAdmin };

  // Check for stored overrides
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored) {
    try {
      const overrides = JSON.parse(stored);
      profile = { ...profile, ...overrides };
    } catch (e) {
      console.warn("[Profile] Stored data corrupted, using defaults");
    }
  }

  // Check for LinkedIn data (higher priority)
  const linkedinData = localStorage.getItem(LINKEDIN_DATA_KEY);
  if (linkedinData) {
    try {
      const linkedin = JSON.parse(linkedinData);
      // Merge LinkedIn data if available
      if (linkedin.profile) {
        profile.linkedinData = linkedin;
        profile.dataSource = "linkedin";
      }
    } catch (e) {
      console.warn("[Profile] LinkedIn data corrupted");
    }
  }

  return profile;
}

/**
 * Save admin profile (manual overrides)
 * @param {object} data
 */
export function saveAdminProfile(data) {
  const updated = {
    ...getAdminProfile(),
    ...data,
    lastUpdated: new Date().toISOString(),
    dataSource: "manual",
  };
  localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  console.log("[Profile] Saved admin profile");
  return updated;
}

/**
 * Clear stored overrides, return to hardcoded defaults
 */
export function resetAdminProfile() {
  localStorage.removeItem(STORAGE_KEY);
  console.log("[Profile] Reset to defaults");
  return { ...defaultAdmin };
}

/**
 * Get the effective data source
 * @returns {string} 'hardcoded' | 'linkedin' | 'manual'
 */
export function getDataSource() {
  const profile = getAdminProfile();
  return profile.dataSource || "hardcoded";
}

/**
 * Check if LinkedIn data is being used
 * @returns {boolean}
 */
export function hasLinkedInData() {
  const profile = getAdminProfile();
  return !!(profile.linkedinData && profile.linkedinData.profile);
}

// Export for compatibility
export const getProfile = getAdminProfile;
export const saveProfile = saveAdminProfile;
export const resetProfile = resetAdminProfile;
