library(cluster)
library(factoextra)
library(dplyr)


# Standaryzacja -----------------------------------------------------------

stand <- as.data.frame(scale(Dane))
stand

# Odleg�o�ci --------------------------------------------------------------

odl <- as.matrix(dist(stand, method = "euclidean"))
Odleg <- get_dist(stand)

fviz_dist(Odleg, 
          lab_size = 7,
          order = TRUE,
          gradient = list(low = "#15b509", mid = "#fceb2b", high = "#ff0008"))

# Hierarchiczny Ward ------------------------------------------------------

Hier<-hclust(Odleg,method = "ward.D2")
#PIERWSZA MO�LIWO��
plot(Hier, 
     main = "",
     ylab= "Odleglo��",
     sub = ""
)
rect.hclust(Hier,k=3,border = "blue")


#DRUGA - lepsza
fviz_dend(Hier,
          k=3,
          ylab = "Odleg�o��",
          main = "",
          lwd= 1,
          cex = 0.7,
          horiz = FALSE,
          k_colors=c("#0d58d1","#e80202","#54c40e"),
          rect=TRUE,
          rect_border = c("#87b5ff","#ff8787","#b5ff87"),
          rect_lty = 3,
          rect_fill = FALSE,
          ggtheme = theme_minimal()
)


# Osupisko - k means ------------------------------------------------------

set.seed(123)
fviz_nbclust(stand,kmeans,method="wss")+
  ylim(0,300)+
  ylab("��czna wewn�trzgrupowa suma kwadrat�w")+
  xlab("Liczba skupie� k")+
  labs(title="")+
  theme_classic()


# Silhouette --------------------------------------------------------------

Sylw <- fviz_silhouette(eclust(stand,FUNcluster = "kmeans",k=2))
Sylw[[1]]

#RYSUNEK
fviz_nbclust(stand,kmeans, method = "silhouette")+ 
  ylim(0,0.3)+
  labs(title= "") + 
  xlab("Liczba skupie� k")+
  ylab("�rednia warto�� wska�nika Silhouette")


# K means -----------------------------------------------------------------

ksrednie <- kmeans(stand,2)
#wewnatrzgrup sum kwadrat
ksrednie$tot.withinss
#rozmiar cluster�w
ksrednie$size
#lista z dopasowaniem
ksrednie$cluster

print(ksrednie)
#plot
par(mar=c(3,3,1,1))
fviz_cluster(ksrednie,data = stand,
             ggtheme = theme_minimal(),
             palette = c("#104cb3","#db070e"),
             repel = TRUE,
             show.clust.cent = FALSE,
             main = "",
             pointsize = 2,
             labelsize = 9.3,
             ylab = "Wym2(17,4%)",
             xlab = "Wym1(38.1%)")


#�rednie dla klustr�w

kmeansmean <- Dane %>%
  mutate(Cluster = ksrednie$cluster) %>%
  group_by(Cluster) %>%
  summarise_all("mean") %>% 
  round(digits = 1)


#silhouette w takim uk�adzie
sil <- silhouette(ksrednie$cluster, Odleg)
fviz_silhouette(sil, 
                ylab = "Warto�� wska�nika silhouette",
                main = "",
                ggtheme = theme_minimal(),
                ylim = c(-0.2,0.7),
                palette = c("#104cb3","#db070e"))

#mo�liwo�� sprawdzenia dok�adnych wynik�w wska�nika dla poszczeg�lnych pa�stw
wyksyl <- fviz_silhouette(eclust(stand,FUNcluster = "kmeans",k=2))

wyksyl[[1]]

