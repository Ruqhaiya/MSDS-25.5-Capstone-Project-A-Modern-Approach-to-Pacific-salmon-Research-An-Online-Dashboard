# MSDS-25.5 - NOAA Fisheries Capstone Project (**[Dashboard Link](https://ruqhaiya.shinyapps.io/NOAA_SRF_Dashboard/)**)

#### The app is live on NOAA's server too: **[Link-to-noaa-server](https://connect.fisheries.noaa.gov/salmon_stressor_response_library/)**
#### Check out the slide deck for a quick overview of the project. (I spent an insane amount of time on this deck)
> 🔗 **[SLIDES](https://www.figma.com/slides/AphcX38ejQTjJgArRaCV2j/NOAA_Slides?node-id=59-1146&t=2kh8fvjlamIpNmbh-1)**

#### Check out the word document titled 'MSDS_25.5_Project_Report' for the what-why-and-how of the project. 
> 🔗 **[Report](https://github.com/Ruqhaiya/MSDS-25.5-Capstone-Project-A-Modern-Approach-to-Pacific-salmon-Research-An-Online-Dashboard/blob/main/MSDS_25.5_Project_Report.pdf)**
> 
---

## Abstract (If you're in a hurry):

People hear about Pacific salmon all the time in the Pacific Northwest, but their role goes way beyond just being a regional symbol. They’re a vital part of both the local ecosystem and the economy. As environmental and habitat conditions continue to shift, it’s become harder for scientists to access the kind of data they need to study and protect these fish. NOAA Fisheries, part of the National Oceanic and Atmospheric Administration (NOAA), focuses on managing sustainable fisheries and protecting marine species like Pacific salmon. As part of our capstone project, we partnered with their team to rebuild a key research tool: the Stressor Response Function (SRF) dashboard. The original version developed on an older platform was not compatible with NOAA Fisheries’ current web infrastructure and no longer met the needs of the researchers using it. To solve this, we created a new dashboard using R Shiny, designed to integrate directly with NOAA’s Posit Connect platform. The updated version adds important features like improved search and filtering, interactive visualizations, customizable data exports, a more intuitive interface, and a secure system for uploading and validating new SRF data. We also introduced improvements in data storage by transitioning from JSON to a more scalable SQLite database structure. By centralizing access to SRF data, the dashboard brings everything into one place, making it easier for researchers to work with SRF data and make more informed decisions. Rather than manually combing through articles, users can now compare environmental stressors, salmon life stages, and outcomes across studies—all within a few clicks. With more accessible tools and cleaner data, NOAA Fisheries is better positioned to carry out data-driven salmon conservation and habitat restoration efforts.

---

## Slide deck (If your eyes hate texts, jump to the **[Demo](#demo)**): 

![NOAA_Slide_deckk_pages-to-jpg-0001](https://github.com/user-attachments/assets/57f9c88e-5b5f-424f-b7a7-4ce9ca5b443e)

---

![NOAA_Slide_deckk_pages-to-jpg-0002](https://github.com/user-attachments/assets/f520f0fd-dc62-4244-be32-93ab2037e606)

--- 

![NOAA_Slide_deckk_pages-to-jpg-0003](https://github.com/user-attachments/assets/f8ab8482-d046-45f7-a653-d987fbe28a5c)

---

![NOAA_Slide_deckk_pages-to-jpg-0004](https://github.com/user-attachments/assets/3eef09c5-f9d2-43b7-bddd-71cb96cf411d)

---

![NOAA_Slide_deckk_pages-to-jpg-0005](https://github.com/user-attachments/assets/021fffe7-17aa-4572-b037-e6f8382e6113)

---

![NOAA_Slide_deckk_pages-to-jpg-0006](https://github.com/user-attachments/assets/b91904d2-df3e-43a7-bc54-ad74b583dc0b)

---

![NOAA_Slide_deckk_pages-to-jpg-0007](https://github.com/user-attachments/assets/464fc7c9-bc8f-43f0-9418-a7bf7c2bd018)

---

![NOAA_Slide_deckk_pages-to-jpg-0008](https://github.com/user-attachments/assets/38e4216e-dbcf-4ccb-b04c-11451d85aa6f)

---

![NOAA_Slide_deckk_pages-to-jpg-0009](https://github.com/user-attachments/assets/40c21fa0-51d1-4cec-b79f-601b55303541)

---

![NOAA_Slide_deckk_pages-to-jpg-0010](https://github.com/user-attachments/assets/cac2e79e-89a9-489c-9120-4d2372852196)

---

![NOAA_Slide_deckk_pages-to-jpg-0011](https://github.com/user-attachments/assets/41ce9062-48d4-4e7f-848e-668f7357bc1c)

---

![NOAA_Slide_deckk_pages-to-jpg-0012](https://github.com/user-attachments/assets/1c27774c-5298-44fe-9aa0-9a589ca58951)

---

![NOAA_Slide_deckk_pages-to-jpg-0013](https://github.com/user-attachments/assets/cb5da98d-e492-4372-a9aa-bd2523157d16)

---

![NOAA_Slide_deckk_pages-to-jpg-0014](https://github.com/user-attachments/assets/1db8d6ad-02a3-4b99-bb08-277d22ca48dd)

---

![NOAA_Slide_deckk_pages-to-jpg-0015](https://github.com/user-attachments/assets/554fab85-5efa-43d9-8567-4981136129a1)

---

![NOAA_Slide_deckk_pages-to-jpg-0016](https://github.com/user-attachments/assets/67ba7882-a248-4f27-b130-4af934c9f4de)

---

![NOAA_Slide_deckk_pages-to-jpg-0017](https://github.com/user-attachments/assets/bf6178a2-e30d-4566-bf27-0b9147aaa066)

---

![NOAA_Slide_deckk_pages-to-jpg-0018](https://github.com/user-attachments/assets/a7e9731e-e9b2-463b-9694-3b5d980ee6b5)

---

![NOAA_Slide_deckk_pages-to-jpg-0019](https://github.com/user-attachments/assets/0c049d5a-bf74-4e36-9a5e-5c60cdb98106)

---

![NOAA_Slide_deckk_pages-to-jpg-0020](https://github.com/user-attachments/assets/fa89e748-d8c2-433c-91a5-30def33b9d18)

---

![NOAA_Slide_deckk_pages-to-jpg-0021](https://github.com/user-attachments/assets/d561e3ae-8122-477a-a1d4-1e4e166cbcc7)

---

![NOAA_Slide_deckk_pages-to-jpg-0022](https://github.com/user-attachments/assets/da136769-8c05-423b-aff9-6c0d7ae33e85)

---

![NOAA_Slide_deckk_pages-to-jpg-0023](https://github.com/user-attachments/assets/91aeb8e5-2cb5-4562-bc45-a6eecac31cb0)

---

# DEMO 

![NOAA_Slide_deckk_pages-to-jpg-0024](https://github.com/user-attachments/assets/316185a5-6815-43ea-989c-7117dd122816)

---

![NOAA_Slide_deckk_pages-to-jpg-0025](https://github.com/user-attachments/assets/32ee5ff0-80d6-4924-8427-60a45873128b)

---

![NOAA_Slide_deckk_pages-to-jpg-0026](https://github.com/user-attachments/assets/58b925de-5446-452f-ada8-23c5aea3905e)

---

![NOAA_Slide_deckk_pages-to-jpg-0027](https://github.com/user-attachments/assets/6e8685e3-647c-44b9-a2ea-ac19e6a5d342)

---

![NOAA_Slide_deckk_pages-to-jpg-0028](https://github.com/user-attachments/assets/74a1abf4-dc2a-4a30-901b-02575cae3ba1)

---

![NOAA_Slide_deckk_pages-to-jpg-0029](https://github.com/user-attachments/assets/ee6b305e-9f6e-4186-b0fa-3875389e5500)

---

![NOAA_Slide_deckk_pages-to-jpg-0030](https://github.com/user-attachments/assets/f426e1c7-2ec9-4144-a4e1-3f2556a19d9d)

---

![NOAA_Slide_deckk_pages-to-jpg-0031](https://github.com/user-attachments/assets/627ad4e2-d6ff-4042-aa2d-6d6510be1d85)

---

![NOAA_Slide_deckk_pages-to-jpg-0032](https://github.com/user-attachments/assets/35770b4c-29bd-414e-bb95-6c1d09d01767)

---

![NOAA_Slide_deckk_pages-to-jpg-0033](https://github.com/user-attachments/assets/58ecad6f-c105-43f9-b64f-43f8f2eaceb4)

---

![NOAA_Slide_deckk_pages-to-jpg-0034](https://github.com/user-attachments/assets/8988a469-d730-47af-8e5d-7215ee91cd85)

---

![NOAA_Slide_deckk_pages-to-jpg-0035](https://github.com/user-attachments/assets/056a090e-c8ab-4572-8b85-729650087dfd)

---

![NOAA_Slide_deckk_pages-to-jpg-0036](https://github.com/user-attachments/assets/ec51ccfe-cb51-4ed3-a0e9-ad543685ec08)

---

![NOAA_Slide_deckk_pages-to-jpg-0037](https://github.com/user-attachments/assets/6d17c99f-2f15-4b1c-a9dd-3fc519bd507c)

---

![NOAA_Slide_deckk_pages-to-jpg-0038](https://github.com/user-attachments/assets/1edb0991-5aae-451c-b344-5e3dbaf58ef8)

---

![NOAA_Slide_deckk_pages-to-jpg-0039](https://github.com/user-attachments/assets/28e54488-4b56-4a4f-b200-28bcb4fcc1e3)

---



# Important links:

https://library.noaa.gov/friendly.php?s=Section508/Web

https://library.noaa.gov/Section508/CheckingAccessibility

https://www.geeksforgeeks.org/text-summarization-in-nlp/

https://www.geeksforgeeks.org/subword-tokenization-in-nlp/?ref=ml_lbp
