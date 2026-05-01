import math
from typing import List, Dict

class CropRecommendationEngine:
    """
    AgriAssistant Crop Recommendation Engine.
    Mimics an ML model trained on ICAR soil suitability data for Assam.
    """

    # ICAR Standard Requirements for Assam Crops
    # Format: { crop_name: { n: range, p: range, k: range, ph: range, soil_types: [] } }
    CROP_KNOWLEDGE = [
        {
            "name": "Tea",
            "optimal_n": (50, 150),
            "optimal_p": (20, 50),
            "optimal_k": (40, 100),
            "optimal_ph": (4.5, 5.5),
            "soil_types": ["loamy", "clay", "peaty"],
            "sowing_month": "March",
            "harvest_month": "October"
        },
        {
            "name": "Rice (Sali)",
            "optimal_n": (60, 100),
            "optimal_p": (30, 60),
            "optimal_k": (30, 60),
            "optimal_ph": (5.5, 7.0),
            "soil_types": ["clay", "loamy", "silty"],
            "sowing_month": "June",
            "harvest_month": "November"
        },
        {
            "name": "Pineapple",
            "optimal_n": (40, 80),
            "optimal_p": (20, 40),
            "optimal_k": (50, 120),
            "optimal_ph": (4.5, 6.0),
            "soil_types": ["sandy", "loamy", "peaty"],
            "sowing_month": "April",
            "harvest_month": "August"
        },
        {
            "name": "Jute",
            "optimal_n": (40, 60),
            "optimal_p": (20, 40),
            "optimal_k": (40, 80),
            "optimal_ph": (6.0, 7.5),
            "soil_types": ["loamy", "silty"],
            "sowing_month": "March",
            "harvest_month": "July"
        },
        {
            "name": "Black Pepper",
            "optimal_n": (40, 70),
            "optimal_p": (20, 50),
            "optimal_k": (60, 120),
            "optimal_ph": (5.0, 6.5),
            "soil_types": ["loamy", "clay"],
            "sowing_month": "May",
            "harvest_month": "January"
        }
    ]

    def calculate_score(self, val, optimal_range):
        low, high = optimal_range
        if low <= val <= high:
            return 1.0
        # Linear penalty for being outside range
        diff = min(abs(val - low), abs(val - high))
        score = max(0, 1.0 - (diff / (high - low if high > low else 10)))
        return score

    def recommend(self, n: float, p: float, k: float, ph: float, soil_type: str) -> List[Dict]:
        recommendations = []

        for crop in self.CROP_KNOWLEDGE:
            # 1. PH Score (Heaviest weight for Assam soils)
            ph_score = self.calculate_score(ph, crop["optimal_ph"])
            
            # 2. Nutrient Scores
            n_score = self.calculate_score(n, crop["optimal_n"])
            p_score = self.calculate_score(p, crop["optimal_p"])
            k_score = self.calculate_score(k, crop["optimal_k"])
            
            # 3. Soil Type Match
            soil_match = 1.0 if soil_type.lower() in crop["soil_types"] else 0.5
            
            # Weighted average
            # pH is critical, then nutrients, then soil type
            confidence = (ph_score * 0.4) + (n_score * 0.15) + (p_score * 0.15) + (k_score * 0.15) + (soil_match * 0.15)
            
            recommendations.append({
                "crop_name": crop["name"],
                "confidence_score": round(confidence * 100, 2),
                "sowing_month": crop["sowing_month"],
                "harvest_month": crop["harvest_month"],
                "reasoning": f"Matches {soil_type} soil with pH {ph}. Optimal NPK requirements overlap significantly."
            })

        # Sort by confidence
        recommendations.sort(key=lambda x: x["confidence_score"], reverse=True)
        return recommendations[:5]
