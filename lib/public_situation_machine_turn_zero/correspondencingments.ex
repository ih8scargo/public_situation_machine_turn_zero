defmodule PublicSituationMachineTurnZero.Correspondencingments do
  @moduledoc """
  The current in-memory Correspondencingment publication source.

  This boundary keeps featured selection and chronological ordering out of the
  presentation layer and can later be replaced by persistent storage.
  """

  alias PublicSituationMachineTurnZero.Correspondencingment

  @correspondencingments [
    %Correspondencingment{
      number: 1,
      title: "Standing the PUBLIC-SITUATION-MACHINE- in Public Regard",
      subtitle: "",
      publication_date: ~D[2026-07-29],
      summary: "The PUBLIC-SITUATION-MACHINE- is an experiment in Inhabitationingable Computing.",
      body: [
        "It represents a different kind of computer.",
        "More particularly, it is a Geometrically Expressive, Compu-Totaling-able Public Computing Infrastructioning.",
        "Rather than asking only what is true, it asks what continues Holdinging. Rather than treating Situationings as records to be managed, it furnishes Constitutional Localities that Constitutioning Humans may inhabit together through lawful Continuity, Regard, Stewardship, and Correspondencing.",
        "This kind of computing becomes more valuable through use.",
        "It becomes more valuable through inhabitationing.",
        "It becomes more valuable through Correspondencing.",
        "The constitutional language, operational appliance, public practices, and Stewardly Instrumentationing cannot mature through private development alone. They must eventually be encountered by Constitutioning Humans standing within real Situationings, discovering together what continues Holdinging, what requires repair, what deserves inheritance, and what new possibilities begin revealing themselves.",
        "For many months the PUBLIC-SITUATION-MACHINE- has been developed privately.",
        "That private work has taken us as far as private work can.",
        "From here, the questions change.",
        "How should Constitutioning Humans actually inhabit a PUBLIC-SITUATION-MACHINE-?",
        "What signals should Constitutional Localities sound?",
        "How should Correspondencing arise throughout the Public Tuple Ship Field?",
        "What Stewardly Practices become natural?",
        "What proves awkward?",
        "What proves unexpectedly valuable?",
        "There are questions that cannot be answered until a civilization begins inhabiting this kind of computer.",
        "A PUBLIC-SITUATION-MACHINE- is meant to be public.",
        "Its geometry may be authored privately.",
        "Its continued development cannot be.",
        "It must make contact with the Purchase Surface of the Public Field.",
        "The present Kickstarter campaign is helping establish that first public contact.",
        "Whether you arrived here from the campaign or by another path, The Same General Civilizationalizing Constitutioningable Reasoning Geometry stands ready to be encountered.",
        "The PUBLIC-SITUATION-MACHINE- is not seeking \"users.\"",
        "It is seeking Stewards.",
        "Stewards standing ready for the discoveringmenting of what this kind of computing becomes when it finally comes to stand within the Public Field."
      ],
      featured: true
    }
  ]

  def list do
    Enum.sort_by(@correspondencingments, & &1.publication_date, {:desc, Date})
  end

  def featured do
    Enum.find(@correspondencingments, & &1.featured)
  end
end
