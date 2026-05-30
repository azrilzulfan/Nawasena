// src/types/index.js

/**
 * @typedef {Object} User
 * @property {string} _id
 * @property {string} full_name
 * @property {string} email
 * @property {'admin'|'donor'|'volunteer'|'foundation_admin'} role
 * @property {string} [avatar_url]
 * @property {VolunteerProfile} [volunteer_profile]
 * @property {string} [managed_foundation_id]
 * @property {string} created_at
 */

/**
 * @typedef {Object} VolunteerProfile
 * @property {string[]} skills
 * @property {number} volunteer_hours
 * @property {number} workshops_attended
 */

/**
 * @typedef {Object} Foundation
 * @property {string} _id
 * @property {string} name
 * @property {string} description
 * @property {string} address
 * @property {{ type: 'Point', coordinates: [number, number] }} location
 * @property {string} contact_phone
 * @property {string[]} verification_docs
 * @property {boolean} is_verified
 * @property {{ bank_name: string, account_number: string, account_name: string }} [bank_account]
 * @property {string} admin_id
 * @property {string} created_at
 */

/**
 * @typedef {Object} FoundationAnalytics
 * @property {{ total: number, by_status: Record<string, number> }} donations
 * @property {{ total_items: number, urgent_items: number, items: InventorySummaryItem[] }} inventory
 * @property {{ total_registered: number, total_workshops: number }} volunteers
 */

/**
 * @typedef {Object} Inventory
 * @property {string} _id
 * @property {string} foundation_id
 * @property {string} item_name
 * @property {'Logistik'|'Edukasi'|'Medis'} category
 * @property {string} unit
 * @property {number} target_qty
 * @property {number} current_qty
 * @property {'high'|'medium'|'low'} urgent_level
 * @property {string} [description]
 */

/**
 * @typedef {Object} ItemDetail
 * @property {string} name
 * @property {number} qty
 * @property {string} unit
 */

/**
 * @typedef {Object} Donation
 * @property {string} _id
 * @property {string} donor_id
 * @property {string} foundation_id
 * @property {string} inventory_id
 * @property {'goods'|'money'} type
 * @property {ItemDetail} item_detail
 * @property {'pending'|'sent'|'received'|'verified'} status
 * @property {boolean} is_anonymous
 * @property {string} qr_code_hash
 * @property {{ status: string, timestamp: string, note: string, proof_image?: string }[]} history_logs
 * @property {string} created_at
 */

/**
 * @typedef {Object} Workshop
 * @property {string} _id
 * @property {string} foundation_id
 * @property {string} title
 * @property {string} description
 * @property {string} event_date
 * @property {'open'|'closed'|'finished'} status
 * @property {number} mentor_needed
 * @property {number} mentor_registered_count
 * @property {{ user_id: string, status: string }[]} registered_volunteers
 * @property {{ type: 'Point', coordinates: [number, number] }} location
 * @property {number} [geofence_radius_meters]
 */