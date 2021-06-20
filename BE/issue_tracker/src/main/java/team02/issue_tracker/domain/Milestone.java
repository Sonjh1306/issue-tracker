package team02.issue_tracker.domain;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.Where;
import team02.issue_tracker.dto.MilestoneRequest;

import javax.persistence.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@SQLDelete(sql = "UPDATE milestone SET is_deleted = true WHERE id = ?")
@Where(clause = "is_deleted = false")
public class Milestone {

    @Id
    @GeneratedValue
    private Long id;

    private String title;
    private String content;
    private LocalDate createdDate;
    private LocalDate dueDate;
    private boolean isOpen;
    private boolean isDeleted;

    @OneToMany(mappedBy = "milestone", fetch = FetchType.LAZY)
    private List<Issue> issues = new ArrayList<>();

    public Milestone(String title, String content, LocalDate dueDate) {
        this.title = title;
        this.content = content;
        this.dueDate = dueDate;
        this.createdDate = LocalDate.now();
        this.isOpen = true;
    }

    public int getTotalIssueCount() {
        return (int) issues.stream()
                .filter(issue -> !issue.isDeleted())
                .count();
    }

    public int getOpenIssueCount() {
        return (int) issues.stream()
                .filter(issue -> !issue.isDeleted())
                .filter(Issue::isOpen)
                .count();
    }

    public int getClosedIssueCount() {
        return (int) issues.stream()
                .filter(issue -> !issue.isDeleted())
                .filter(issue -> !issue.isOpen())
                .count();
    }

    public void edit(MilestoneRequest milestoneRequest) {
        this.title = milestoneRequest.getTitle();
        this.content = milestoneRequest.getContent();
        this.dueDate = milestoneRequest.getDueDate();
    }

    public void delete() {
        isDeleted = true;
        issues.stream()
                .forEach(issue -> issue.deleteMilestone());
    }
}
